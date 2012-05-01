Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id CCDDE6B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 14:09:20 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so2940042ghr.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 11:09:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA023E4.7000602@openvz.org>
References: <20120430112903.14137.81692.stgit@zurg> <20120430112907.14137.18910.stgit@zurg>
 <CAHGf_=pfiFJ4N3bN_c29UpffqkzDY_priBYBuEOCyPJ13JVecw@mail.gmail.com> <4FA023E4.7000602@openvz.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 1 May 2012 14:08:59 -0400
Message-ID: <CAHGf_=qh1eogM2cywMrJnhHtcbW9gav4Ktb8inYJmar2wG4j=Q@mail.gmail.com>
Subject: Re: [PATCH RFC 2/3] proc/smaps: show amount of nonlinear ptes in vma
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, May 1, 2012 at 1:56 PM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> KOSAKI Motohiro wrote:
>>
>> On Mon, Apr 30, 2012 at 7:29 AM, Konstantin Khlebnikov
>> <khlebnikov@openvz.org> =A0wrote:
>>>
>>> Currently, nonlinear mappings can not be distinguished from ordinary
>>> mappings.
>>> This patch adds into /proc/pid/smaps line "Nonlinear:<size> =A0kB", whe=
re
>>> size is
>>> amount of nonlinear ptes in vma, this line appears only if VM_NONLINEAR
>>> is set.
>>> This information may be useful not only for checkpoint/restore project.
>>>
>>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>> Requested-by: Pavel Emelyanov<xemul@parallels.com>
>>> ---
>>> =A0fs/proc/task_mmu.c | =A0 12 ++++++++++++
>>> =A01 file changed, 12 insertions(+)
>>>
>>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>>> index acee5fd..b1d9729 100644
>>> --- a/fs/proc/task_mmu.c
>>> +++ b/fs/proc/task_mmu.c
>>> @@ -393,6 +393,7 @@ struct mem_size_stats {
>>> =A0 =A0 =A0 =A0unsigned long anonymous;
>>> =A0 =A0 =A0 =A0unsigned long anonymous_thp;
>>> =A0 =A0 =A0 =A0unsigned long swap;
>>> + =A0 =A0 =A0 unsigned long nonlinear;
>>> =A0 =A0 =A0 =A0u64 pss;
>>> =A0};
>>>
>>> @@ -402,6 +403,7 @@ static void smaps_pte_entry(pte_t ptent, unsigned
>>> long addr,
>>> =A0{
>>> =A0 =A0 =A0 =A0struct mem_size_stats *mss =3D walk->private;
>>> =A0 =A0 =A0 =A0struct vm_area_struct *vma =3D mss->vma;
>>> + =A0 =A0 =A0 pgoff_t pgoff =3D linear_page_index(vma, addr);
>>> =A0 =A0 =A0 =A0struct page *page =3D NULL;
>>> =A0 =A0 =A0 =A0int mapcount;
>>>
>>> @@ -414,6 +416,9 @@ static void smaps_pte_entry(pte_t ptent, unsigned
>>> long addr,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mss->swap +=3D ptent_siz=
e;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else if (is_migration_entry(swpent))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page =3D migration_entry=
_to_page(swpent);
>>> + =A0 =A0 =A0 } else if (pte_file(ptent)) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pte_to_pgoff(ptent) !=3D pgoff)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mss->nonlinear +=3D ptent=
_size;
>>
>>
>> I think this is not equal to our non linear mapping definition. Even if
>> pgoff is equal to linear mapping case, it is non linear. I.e. nonlinear =
is
>> vma attribute. Why do you want to introduce different definition?
>
> VMA attribute can be determined via presence of this field,
> without VM_NONLINEAR it does not appears.

I meant, is there any worth?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
