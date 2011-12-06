Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 0B4296B0062
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 15:43:56 -0500 (EST)
Received: by qadc12 with SMTP id c12so2190484qad.14
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 12:43:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1112061214590.28251@chino.kir.corp.google.com>
References: <CALCETrW1mpVCz2tO5roaz1r6vnno+srHR-dHA6_pkRi2qiCfdw@mail.gmail.com>
 <CAJd=RBDdirdNiPMVcYLNFO5Ho+pRGCfh_RRA7_re+76Ds+H0pw@mail.gmail.com>
 <CALCETrVL3MUMh2kDPaZ6Z9Lz=eWas_dF0jwWMiF3KvNUcJKXJw@mail.gmail.com> <alpine.DEB.2.00.1112061214590.28251@chino.kir.corp.google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 6 Dec 2011 12:43:34 -0800
Message-ID: <CALCETrW77ZE62dbHJxoL3Ef1gAGeMQaSZrOOiM1_ZrY53zbxUQ@mail.gmail.com>
Subject: Re: hugetlb oops on 3.1.0-rc8-devel
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 6, 2011 at 12:16 PM, David Rientjes <rientjes@google.com> wrote=
:
> On Wed, 2 Nov 2011, Andy Lutomirski wrote:
>
>> > --- a/mm/hugetlb.c =A0 =A0 =A0Sat Aug 13 11:45:14 2011
>> > +++ b/mm/hugetlb.c =A0 =A0 =A0Wed Nov =A02 20:12:00 2011
>> > @@ -2422,6 +2422,8 @@ retry_avoidcopy:
>> > =A0 =A0 =A0 =A0 * anon_vma prepared.
>> > =A0 =A0 =A0 =A0 */
>> > =A0 =A0 =A0 =A0if (unlikely(anon_vma_prepare(vma))) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_release(new_page);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_release(old_page);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Caller expects lock to be held */
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&mm->page_table_lock);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return VM_FAULT_OOM;
>> >
>>
>> I'll patch it in. =A0My test case took over a week to hit it once, so I
>> can't guarantee I'll spot it.
>>
>
> This patch was merged and released in 3.2-rc3 as ea4039a34c4c ("hugetlb:
> release pages in the error path of hugetlb_cow()"), Andy is this issue
> fixed for you?

I haven't seen it again with or without the patch.  I suspect that to
trigger it again I'd have to set up an old, buggy version of my
software to hammer on it for awhile, which I won't have a chance to do
any time soon.  Sorry.

If you're interested, the workload that triggered the problem was,
roughly, two programs.  Both were set up to use libhugetlbfs for
everything, and the first program spawned (presumably via fork as
opposed to any clone magic) copies of the second program frequently.
The second program was very memory intensive.  The result was that,
occasionally, fork had issues because it couldn't find free huge pages
in the pool.

--Andy

--=20
Andy Lutomirski
AMA Capital Management, LLC
Office: (310) 553-5322
Mobile: (650) 906-0647

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
