From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: mm, virtio: possible OOM lockup at virtballoon_oom_notify()
Date: Mon, 11 Sep 2017 19:27:19 +0900
Message-ID: <201709111927.IDD00574.tFVJHLOSOOMQFF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
To: mst@redhat.com, jasowang@redhat.com
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org
List-Id: linux-mm.kvack.org

Hello.

I noticed that virtio_balloon is using register_oom_notifier() and
leak_balloon() from virtballoon_oom_notify() might depend on
__GFP_DIRECT_RECLAIM memory allocation.

In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
serialize against fill_balloon(). But in fill_balloon(),
alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE] implies
__GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, this allocation attempt might
depend on somebody else's __GFP_DIRECT_RECLAIM | !__GFP_NORETRY memory
allocation. Such __GFP_DIRECT_RECLAIM | !__GFP_NORETRY allocation can reach
__alloc_pages_may_oom() and hold oom_lock mutex and call out_of_memory().
And leak_balloon() is called by virtballoon_oom_notify() via
blocking_notifier_call_chain() callback when vb->balloon_lock mutex is already
held by fill_balloon(). As a result, despite __GFP_NORETRY is specified,
fill_balloon() can indirectly get stuck waiting for vb->balloon_lock mutex
at leak_balloon().

Also, in leak_balloon(), virtqueue_add_outbuf(GFP_KERNEL) is called via
tell_host(). Reaching __alloc_pages_may_oom() from this virtqueue_add_outbuf()
request from leak_balloon() from virtballoon_oom_notify() from
blocking_notifier_call_chain() from out_of_memory() leads to OOM lockup
because oom_lock mutex is already held before calling out_of_memory().

OOM notifier callback should not (directly or indirectly) depend on
__GFP_DIRECT_RECLAIM memory allocation attempt. Can you fix this dependency?
