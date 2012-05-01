Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 687986B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 13:56:58 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so3174657lbj.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 10:56:56 -0700 (PDT)
Message-ID: <4FA023E4.7000602@openvz.org>
Date: Tue, 01 May 2012 21:56:52 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC 2/3] proc/smaps: show amount of nonlinear ptes in
 vma
References: <20120430112903.14137.81692.stgit@zurg> <20120430112907.14137.18910.stgit@zurg> <CAHGf_=pfiFJ4N3bN_c29UpffqkzDY_priBYBuEOCyPJ13JVecw@mail.gmail.com>
In-Reply-To: <CAHGf_=pfiFJ4N3bN_c29UpffqkzDY_priBYBuEOCyPJ13JVecw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

KOSAKI Motohiro wrote:
> On Mon, Apr 30, 2012 at 7:29 AM, Konstantin Khlebnikov
> <khlebnikov@openvz.org>  wrote:
>> Currently, nonlinear mappings can not be distinguished from ordinary mappings.
>> This patch adds into /proc/pid/smaps line "Nonlinear:<size>  kB", where size is
>> amount of nonlinear ptes in vma, this line appears only if VM_NONLINEAR is set.
>> This information may be useful not only for checkpoint/restore project.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>> Requested-by: Pavel Emelyanov<xemul@parallels.com>
>> ---
>>   fs/proc/task_mmu.c |   12 ++++++++++++
>>   1 file changed, 12 insertions(+)
>>
>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> index acee5fd..b1d9729 100644
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -393,6 +393,7 @@ struct mem_size_stats {
>>         unsigned long anonymous;
>>         unsigned long anonymous_thp;
>>         unsigned long swap;
>> +       unsigned long nonlinear;
>>         u64 pss;
>>   };
>>
>> @@ -402,6 +403,7 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
>>   {
>>         struct mem_size_stats *mss = walk->private;
>>         struct vm_area_struct *vma = mss->vma;
>> +       pgoff_t pgoff = linear_page_index(vma, addr);
>>         struct page *page = NULL;
>>         int mapcount;
>>
>> @@ -414,6 +416,9 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
>>                         mss->swap += ptent_size;
>>                 else if (is_migration_entry(swpent))
>>                         page = migration_entry_to_page(swpent);
>> +       } else if (pte_file(ptent)) {
>> +               if (pte_to_pgoff(ptent) != pgoff)
>> +                       mss->nonlinear += ptent_size;
>
> I think this is not equal to our non linear mapping definition. Even if
> pgoff is equal to linear mapping case, it is non linear. I.e. nonlinear is
> vma attribute. Why do you want to introduce different definition?

VMA attribute can be determined via presence of this field,
without VM_NONLINEAR it does not appears.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
