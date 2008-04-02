From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v4)
Date: Wed, 2 Apr 2008 12:53:47 -0700
Message-ID: <6599ad830804021253y6bf3b37y9bf1167b63c32e70@mail.gmail.com>
References: <20080401124312.23664.64616.sendpatchset@localhost.localdomain>
	 <47F3D62E.4070808@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760591AbYDBTyY@vger.kernel.org>
In-Reply-To: <47F3D62E.4070808@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Wed, Apr 2, 2008 at 11:53 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  So far I've heard no objections or seen any review suggestions. Paul if you are
>  OK with this patch, I'll ask Andrew to include it in -mm.

My only thoughts were:

- I think I'd still prefer CONFIG_MM_OWNER to be auto-selected rather
than manually configured, but it's not a huge deal either way.

- in theory I think we should goto retry if we get to the end of
mm_update_next_owner() without finding any other owner. Otherwise we
could miss another user if we race with one process forking a new
child and then exiting?

- I was looking through the exit code trying to convince myself that
current is still on the tasklist until after it makes this call. If it
isn't then we could have trouble finding the new owner. But I can't
figure out for sure exactly at what point we come off the tasklist.

- I think we only need the cgroup callback in the event that
current->cgroups != new_owner->cgroups. (Hmm, have we already been
moved back to the root cgroup by this point? If so, then we'll have no
way to know which cgruop to unaccount from).

Paul

>
>  People waiting on this patch
>
>  1. Pekka Enberg for revoke* syscalls
>  2. Serge Hallyn for swap namespaces
>  3. Myself to implement the rlimit controller for cgroups
>
>
>
>  --
>         Warm Regards,
>         Balbir Singh
>         Linux Technology Center
>         IBM, ISTL
>
