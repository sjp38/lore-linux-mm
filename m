Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9CCC16B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 19:06:40 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o91N6bxa004287
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 16:06:37 -0700
Received: from qyk4 (qyk4.prod.google.com [10.241.83.132])
	by hpaq6.eem.corp.google.com with ESMTP id o91N5SMm025903
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 16:06:36 -0700
Received: by qyk4 with SMTP id 4so1739909qyk.2
        for <linux-mm@kvack.org>; Fri, 01 Oct 2010 16:06:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTinGgZC7eHW_Q-aR5Vmur4yjv_kKSJ8z3MX60e-r@mail.gmail.com>
References: <1285909484-30958-1-git-send-email-walken@google.com>
	<1285909484-30958-3-git-send-email-walken@google.com>
	<AANLkTinGgZC7eHW_Q-aR5Vmur4yjv_kKSJ8z3MX60e-r@mail.gmail.com>
Date: Fri, 1 Oct 2010 16:06:35 -0700
Message-ID: <AANLkTi=3hscMOo6Ho_RbCT82eUZ_Scz_e_9KGQAdKwAs@mail.gmail.com>
Subject: Re: [PATCH 2/2] Release mmap_sem when page fault blocks on disk transfer.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 1, 2010 at 8:31 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> Also, I think the "RELEASE" naming is too much about the
> implementation, not about the context. I think it would be more
> sensible to call it "ALLOW_RETRY" or "ATOMIC" or something like this,
> and not make it about releasing the page lock so much as about what
> you want to happen.
>
> Because quite frankly, I could imagine other reasons to allow page fault =
retry.
>
> (Similarly, I would rename VM_FAULT_RELEASED to VM_FAULT_RETRY. Again:
> name things for the _concept_, not for some odd implementation issue)

All right, I changed for your names and I think they do help. There is
still one annoyance though (and this is why I had not made this purely
about retry in the first iteration): the up_read(mmap_sem) and the
wait_on_page_locked(page) still happen within filemap_fault(). I think
ideally we would prefer to move this into do_page_fault so that the
interface could *really* be about retry; however we can't easily do
that because the struct page is not exposed at that level.

>
>> - =A0 =A0 =A0 if (fault & VM_FAULT_MAJOR) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk->maj_flt++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MA=
J, 1, 0,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0regs, address);
>> - =A0 =A0 =A0 } else {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk->min_flt++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MI=
N, 1, 0,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0regs, address);
>> + =A0 =A0 =A0 if (release_flag) { =A0 =A0 /* Did not go through a retry =
*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (fault & VM_FAULT_MAJOR) {
>
> I really don't know if this is correct. What if you have two major
> faults due to the retry? What if the first one is a minor fault, but
> when we retry it's a major fault because the page got released? The
> nesting of the conditionals doesn't seem to make conceptual sense.
>
> I dunno. I can see what you're doing ("only do statistics for the
> first return"), but at the same time it just feels a bit icky.

In a way filemap_fault() already has that problem - during a minor
fault, the page could go away before we have a chance to lock it, and
the fault would still be counted as minor. So I just took that
property (first find_get_page() determines if we call the fault minor
or major) and extended it into the retry case.

One reasonable alternative, I think, would be to always count the
fault as major if we had to go through the retry path. The main
difference this would make, I think, is if two threads hit the exact
same page before we get a chance to load it from disk - in which case
they would both get counted as major faults, vs the current accounting
that would charge one as major and the other one as minor.

>> - =A0 =A0 =A0 lock_page(page);
>> + =A0 =A0 =A0 /* Lock the page. */
>> + =A0 =A0 =A0 if (!trylock_page(page)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(vmf->flags & FAULT_FLAG_RELEASE))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __lock_page(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Caller passed FAULT_F=
LAG_RELEASE flag.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This indicates it has=
 read-acquired mmap_sem,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and requests that it =
be released if we have to
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* wait for the page to =
be transferred from disk.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Caller will then retr=
y starting with the
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mmap_sem read-acquire=
