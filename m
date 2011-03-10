Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6397B8D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 12:16:59 -0500 (EST)
References: <1299630721-4337-1-git-send-email-wilsons@start.ca> <20110310160032.GA20504@alboin.amr.corp.intel.com> <20110310164022.GA6242@fibrous.localdomain>
In-Reply-To: <20110310164022.GA6242@fibrous.localdomain>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="----3X4K0B2TLOA62KIFLERUUQW17HJVJU"
Subject: =?US-ASCII?Q?Re=3A_=5BPATCH_0/5=5D_make_*=5Fgate=5Fvma_acc?= =?US-ASCII?Q?ept_mm=5Fstruct_instead_of=09task=5Fstruct?=
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Thu, 10 Mar 2011 09:15:56 -0800
Message-ID: <bba01c29-0f31-4e3b-9839-4048b47bbd17@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>, Andi Kleen <ak@linux.intel.com>
Cc: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Paul Mundt <lethal@linux-sh.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

------3X4K0B2TLOA62KIFLERUUQW17HJVJU
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit

TIF_IA32 is set during the execution of a 32-bit system call - so touched on each compat system call. Is this the actual flag you want? A 32-bit address space flag is different from TIF_IA32.
-- 
Sent from my mobile phone. Please pardon any lack of formatting.

Stephen Wilson <wilsons@start.ca> wrote:

On Thu, Mar 10, 2011 at 08:00:32AM -0800, Andi Kleen wrote: > On Tue, Mar 08, 2011 at 07:31:56PM -0500, Stephen Wilson wrote: > > > > Morally, the question of whether an address lies in a gate vma should be asked > > with respect to an mm, not a particular task. > > > > Practically, dropping the dependency on task_struct will help make current and > > future operations on mm's more flexible and convenient. In particular, it > > allows some code paths to avoid the need to hold task_lock. > > > > The only architecture this change impacts in any significant way is x86_64. > > The principle change on that architecture is to mirror TIF_IA32 via > > a new flag in mm_context_t. > > The problem is -- you're adding a likely cache miss on mm_struct for > every 32bit compat syscall now, even if they don't need mm_struct > currently (and a lot of them do not) Unless there's a very good > justification to make up for this performance issue elsewhere > (including numbers) this seems like !
 a bad
idea. I do not think this will result in cache misses on the scale you suggest. I am simply mirroring the *state* of the TIF_IA32 flag in mm_struct, not testing/accessing it in the same way. The only place where this flag is accessed (outside the exec() syscall path) is in x86/mm/init_64.c, get_gate_vma(), which in turn is needed by a few, relatively heavy weight, page locking/pinning routines on the mm side (get_user_pages, for example). Patches 3 and 4 in the series show the extent of the change. Or am I missing something? > > /proc/pid/mem. I will be posting the second series to lkml shortly. These > > Making every syscall slower for /proc/pid/mem doesn't seem like a good > tradeoff to me. Please solve this in some other way. > > -Andi -- steve 


------3X4K0B2TLOA62KIFLERUUQW17HJVJU
Content-Type: text/html;
 charset=utf-8
Content-Transfer-Encoding: 8bit

<html><head></head><body>TIF_IA32 is set during the execution of a 32-bit system call - so touched on each compat system call. Is this the actual flag you want? A 32-bit address space flag is different from TIF_IA32.<br>
-- <br>
Sent from my mobile phone.  Please pardon any lack of formatting.<br><br><div class="gmail_quote">Stephen Wilson &lt;wilsons@start.ca&gt; wrote:<blockquote class="gmail_quote" style="margin: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
<div style="white-space: pre-wrap; word-wrap:break-word; ">
On Thu, Mar 10, 2011 at 08:00:32AM -0800, Andi Kleen wrote:
&gt; On Tue, Mar 08, 2011 at 07:31:56PM -0500, Stephen Wilson wrote:
&gt; &gt; 
&gt; &gt; Morally, the question of whether an address lies in a gate vma should be asked
&gt; &gt; with respect to an mm, not a particular task.
&gt; &gt; 
&gt; &gt; Practically, dropping the dependency on task_struct will help make current and
&gt; &gt; future operations on mm's more flexible and convenient.  In particular, it
&gt; &gt; allows some code paths to avoid the need to hold task_lock.
&gt; &gt; 
&gt; &gt; The only architecture this change impacts in any significant way is x86_64.
&gt; &gt; The principle change on that architecture is to mirror TIF_IA32 via
&gt; &gt; a new flag in mm_context_t. 
&gt; 
&gt; The problem is -- you're adding a likely cache miss on mm_struct for
&gt; every 32bit compat syscall now, even if they don't need mm_struct
&gt; currently (and a lot of them do not) Unless there's a very good
&gt; justification to make up for this performance issue elsewhere
&gt; (including numbers) this seems like a bad idea.

I do not think this will result in cache misses on the scale you suggest.  I am simply mirroring the *state* of the TIF_IA32 flag in mm_struct, not testing/accessing it in the same way.

The only place where this flag is accessed (outside the exec() syscall path) is in x86/mm/init_64.c, get_gate_vma(),  which in turn is needed by a few, relatively heavy weight, page locking/pinning routines on the mm side (get_user_pages, for example).  Patches 3 and 4 in the series show the extent of the change.

Or am I missing something?


&gt; &gt; /proc/pid/mem.  I will be posting the second series to lkml shortly.  These
&gt; 
&gt; Making every syscall slower for /proc/pid/mem doesn't seem like a good
&gt; tradeoff to me. Please solve this in some other way.
&gt; 
&gt; -Andi

-- 
steve

</div></blockquote></div></body></html>
------3X4K0B2TLOA62KIFLERUUQW17HJVJU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
