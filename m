Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EFCF26B006E
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 13:19:12 -0400 (EDT)
Received: by gyg10 with SMTP id 10so497080gyg.14
        for <linux-mm@kvack.org>; Wed, 02 Nov 2011 10:19:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBDdirdNiPMVcYLNFO5Ho+pRGCfh_RRA7_re+76Ds+H0pw@mail.gmail.com>
References: <CALCETrW1mpVCz2tO5roaz1r6vnno+srHR-dHA6_pkRi2qiCfdw@mail.gmail.com>
 <CAJd=RBDdirdNiPMVcYLNFO5Ho+pRGCfh_RRA7_re+76Ds+H0pw@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 2 Nov 2011 10:18:50 -0700
Message-ID: <CALCETrVL3MUMh2kDPaZ6Z9Lz=eWas_dF0jwWMiF3KvNUcJKXJw@mail.gmail.com>
Subject: Re: hugetlb oops on 3.1.0-rc8-devel
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 2, 2011 at 5:06 AM, Hillf Danton <dhillf@gmail.com> wrote:
> On Wed, Nov 2, 2011 at 6:20 AM, Andy Lutomirski <luto@amacapital.net> wro=
te:
>> The line that crashed is BUG_ON(page_count(old_page) !=3D 1) in hugetlb_=
cow.
>>
>
> Hello Andy
>
> Would you please try the following patch?
>
> Thanks
> =A0 =A0 =A0 =A0Hillf
>
>
> --- a/mm/hugetlb.c =A0 =A0 =A0Sat Aug 13 11:45:14 2011
> +++ b/mm/hugetlb.c =A0 =A0 =A0Wed Nov =A02 20:12:00 2011
> @@ -2422,6 +2422,8 @@ retry_avoidcopy:
> =A0 =A0 =A0 =A0 * anon_vma prepared.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (unlikely(anon_vma_prepare(vma))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_release(new_page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_release(old_page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Caller expects lock to be held */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&mm->page_table_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return VM_FAULT_OOM;
>

I'll patch it in.  My test case took over a week to hit it once, so I
can't guarantee I'll spot it.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
