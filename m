Date: Fri, 1 Feb 2008 01:13:55 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: mmu_notifier: Move mmu_notifier_release up to get rid of the
	invalidat_all() callback
Message-ID: <20080201001355.GU7185@v2.random>
References: <20080131045750.855008281@sgi.com> <20080131045812.785269387@sgi.com> <20080131123118.GK7185@v2.random> <Pine.LNX.4.64.0801311355260.27804@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0801311421110.22290@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801311421110.22290@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2008 at 02:21:58PM -0800, Christoph Lameter wrote:
> Is this okay for KVM too?

->release isn't implemented at all in KVM, only the list_del generates
complications.

I think current code could be already safe through the mm_count pin,
becasue KVM relies on the fact anybody pinning through mm_count like
KVM does, is forbidden to call unregister and it's forced to wait the
auto-disarming when mm_users hits zero, but I feel like something's
still wrong if I think that I'm not using call_rcu to free the
notifier (OTOH we agreed the list had to be frozen and w/o readers
(modulo _release) before _release is called, so if this initial
assumption is ok it seems I may be safe w/o call_rcu?).

But it's really tricky path. Anyway this is the last of my worries
right now, it works perfectly fine with a single user obviously, and
the moment KVM threads runs remotely through GRU/XPMEM isn't happening
too soon ;) so let's concentrate on the rest first. I can say
hlist_del_init doesn't seem to provide any benefit given nobody could
possibly decide to call register or unregister after _release run.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
