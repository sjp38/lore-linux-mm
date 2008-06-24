Date: Wed, 25 Jun 2008 00:11:50 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [0/2] memrlimit improve error handling
In-Reply-To: <20080620150132.16094.29151.sendpatchset@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0806242240200.6804@blonde.site>
References: <20080620150132.16094.29151.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi Balbir,

Below I've a few comments on this particular patch, then report other
problems I've seen with memrlimits configured into my 2.6.25-rc5-mm3
kernel - I've not tried _using_ them.  My own opinion would be that
-mm already contains enough breakage, we don't need memrlimits yet.

On Fri, 20 Jun 2008, Balbir Singh wrote:
> 
> memrlimit cgroup does not handle error cases after may_expand_vm(). This
> BUG was reported by Kamezawa, with the test case below to reproduce it
> 
> This patch adds better handling support to fix the reported problem.
> 
> Reported-By: kamezawa.hiroyu@jp.fujitsu.com
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

I wrote a similar patch when I saw Kame's report, because I was
interested in getting that accounting right.  Comparing the two,
a couple of notes on the details...

In mm/mmap.c:
> @@ -1982,6 +1992,7 @@ unsigned long do_brk(unsigned long addr,
>  	struct rb_node ** rb_link, * rb_parent;
>  	pgoff_t pgoff = addr >> PAGE_SHIFT;
>  	int error;
> +	int ret = -ENOMEM;

I think we don't want int error returned from some parts of do_brk()
and int ret returned from other parts: please use int error throughout.
It would probably be nicer to add int error rather than int ret in
acct_stack_growth() too, but that doesn't matter much.

In mm/mremap.c:
> @@ -256,6 +257,7 @@ unsigned long do_mremap(unsigned long ad
>  	struct vm_area_struct *vma;
>  	unsigned long ret = -EINVAL;
>  	unsigned long charged = 0;
> +	int vm_expanded = 0;
>  
>  	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
>  		goto out;
> @@ -349,6 +351,7 @@ unsigned long do_mremap(unsigned long ad
>  		goto out;
>  	}
>  
> +	vm_expanded = 1;
>  	if (vma->vm_flags & VM_ACCOUNT) {
>  		charged = (new_len - old_len) >> PAGE_SHIFT;
>  		if (security_vm_enough_memory(charged))
> @@ -411,6 +414,9 @@ out:
>  	if (ret & ~PAGE_MASK)
>  		vm_unacct_memory(charged);
>  out_nc:
> +	if (vm_expanded)
> +		memrlimit_cgroup_uncharge_as(mm,
> +				(new_len - old_len) >> PAGE_SHIFT);
>  	return ret;
>  }

See how vm_unacct_memory(charged) is only called if (ret & ~PAGE_MASK)?
If ret is a valid address being returned, we do not want to uncharge.
So I believe you need to do likewise with your uncharge_as().

And please handle them both in the same way: either follow the same
"charged" style as is being used for vm_unacct_memory, rather than a
boolean; or convert vm_unacct_memory over to use your boolean style:
but it's unhelpful to have the two using different techniques.

In kernel/fork.c:
nothing, but when I had a quick look there, again the error handling
appeared to be broken e.g. if allocate_mm fails, where's the uncharge?
But be careful: there's a particular point where enough of the new mm
is set up that it gets torn down by normal exit_mmap.

And while looking at copy_mm, do I see an extra down_write and
up_write of mmap_sem, just to guard some memrlimit charging?
Don't add overhead when memrlimits are CONFIGed off; but can't
it be moved into dup_mm() where mmap_sem is already down_write?

Please go through all your charges, again, to double check
that you've got the uncharging right in the error cases.

I was interested in these because I find that after running kernel
build on tmpfs swapping loads in a 700M memcg (but you may well hit
other rc5-mm3 bugs if you try that, I've fixes to send out) for some
hours on x86_64, my shutdown hits the kernel/res_counter.c:49
res_counter_uncharge_locked() WARN_ON(counter->usage < val) several
times, called from memrlimit_cgroup_uncharge_as called from exit_mmap.

I have no idea what the cause is; but I've not seen it on i386,
and I'm not seeing it after shorter runs.  It could even be some
error introduced by other patches in what I'm testing: so don't
worry too much about it yet, but please keep an eye out for it.

(If I'd thought harder, I'd have been less interested in the
charge_as leaks: those WARN_ONs come when too much is being
uncharged, not when too little.)

But the issue which worries me most, because it's mislocking
which affects anyone with CONFIG_MM_OWNER=y, is seen when I
have CONFIG_DEBUG_SPINLOCK_SLEEP=y: 

 BUG: sleeping function called from invalid context at kernel/rwsem.c:48
 in_atomic():1, irqs_disabled():0
 1 lock held by blogd/830:
  #0:  (tasklist_lock){..--}, at: [<78125869>] mm_update_next_owner+0x1dd/0x1fa
 Pid: 830, comm: blogd Not tainted 2.6.26-rc5-mm2 #2
  [<78120ea2>] __might_sleep+0xed/0xf2
  [<78367947>] down_write+0x13/0x43
  [<781257b6>] mm_update_next_owner+0x12a/0x1fa
  [<7812595a>] exit_mm+0xd4/0xe5
  [<78125f9d>] do_exit+0x1e7/0x2bc
  [<781260fb>] do_group_exit+0x61/0x8a
  [<78126134>] sys_exit_group+0x10/0x13
  [<78102dd9>] sysenter_past_esp+0x6a/0xa5

Your memrlimit-cgroup-mm-owner-callback-changes-to-add-task-info.patch
thinks it can acquire mmap_sem while it has read_lock(&tasklist_lock).
Sorry, no: you'll have to rework that somehow.

(In passing, I'll add that I'm not a great fan of these memrlimits:
to me it's loony to be charging people for virtual address space,
it's _virtual_, and process A can have as much as it likes without
affecting process B in any way.  You're following the lead of RLIMIT_AS,
but I've always thought RLIMIT_AS a lame attempt to move into the mmap
decade, after RLIMIT_DATA and RLIMIT_STACK no longer made sense.

Taking Alan Cox's Committed_AS as a limited resource charged per mm makes
much more sense to me: but yes, it's not perfect, and it is a lot harder
to get its accounting right, and to maintain that down the line.  Okay,
you've gone for the easier option of tracking total_vm, getting that
right is a more achievable target.  And I accept that I may be too
pessimistic about it: total_vm may often enough give a rough
approximation to something else worth limiting.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
