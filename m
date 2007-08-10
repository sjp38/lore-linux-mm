Date: Thu, 9 Aug 2007 23:15:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 3/3] SGI Altix cross partition memory (XPMEM)
Message-Id: <20070809231542.f6dcce8c.akpm@linux-foundation.org>
In-Reply-To: <20070810011435.GD25427@sgi.com>
References: <20070810010659.GA25427@sgi.com>
	<20070810011435.GD25427@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dean Nelson <dcn@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 9 Aug 2007 20:14:35 -0500 Dean Nelson <dcn@sgi.com> wrote:

> This patch provides cross partition access to user memory (XPMEM) when
> running multiple partitions on a single SGI Altix.
> 

- Please don't send multiple patches all with the same title.

- Feed the diff through checkpatch.pl, ponder the result.

- Avoid needless casts to and from void* (eg, vm_private_data)

- The test for PF_DUMPCORE in xpmem_fault_handler() is mysterious and
  merits a comment.

- xpmem_fault_handler() is scary.

- xpmem_fault_handler() appears to have imposed a kernel-wide rule that
  when taking multiple mmap_sems, one should take the lowest-addressed one
  first?  If so, that probably wants a mention in that locking comment in
  filemap.c

- xpmem_fault_handler() does atomic_dec(&seg_tg->mm->mm_users).  What
  happens if that was the last reference?

- Has it all been tested with lockdep enabled?  Jugding from all the use
  of SPIN_LOCK_UNLOCKED, it has not.

  Oh, ia64 doesn't implement lockdep.  For this code, that is deeply
  regrettable.

- This code all predates the nopage->fault conversion and won't work in
  current kernels.

- xpmem_attach() does smp_processor_id() in preemptible code.  Lucky that
  ia64 doesn't do preempt?

- Stuff like this:

+	ap_tg = xpmem_tg_ref_by_apid(apid);
+	if (IS_ERR(ap_tg))
+		return PTR_ERR(ap_tg);
+
+	ap = xpmem_ap_ref_by_apid(ap_tg, apid);
+	if (IS_ERR(ap)) {
+		xpmem_tg_deref(ap_tg);
+		return PTR_ERR(ap);
+	}

  is fragile.  It is easy to introduce leaks and locking errors as the
  code evolves.  The code has a lot of these deeply-embedded `return'
  statments preceded by duplicated unwinding.  Kenrel code generally
  prefers to do the `goto out' thing.


- "XPMEM_FLAG_VALIDPTEs"?  Someone's pinky got tired at the end ;)

Attention span expired at 19%, sorry.  It's a large patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
