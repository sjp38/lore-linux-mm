Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 94B0D6B0002
	for <linux-mm@kvack.org>; Wed, 15 May 2013 04:30:09 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4F3C83EE0C1
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:30:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 37FD245DD78
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:30:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F8A645DE56
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:30:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 02B841DB8051
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:30:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7710F1DB8043
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:30:07 +0900 (JST)
Message-ID: <51934781.4040704@jp.fujitsu.com>
Date: Wed, 15 May 2013 17:29:53 +0900
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 5/8] vmcore: allocate ELF note segment in the 2nd kernel
 vmalloc memory
References: <20130514015622.18697.77191.stgit@localhost6.localdomain6> <20130514015734.18697.32447.stgit@localhost6.localdomain6> <20130514153552.GG13674@redhat.com>
In-Reply-To: <20130514153552.GG13674@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org

(2013/05/15 0:35), Vivek Goyal wrote:
> On Tue, May 14, 2013 at 10:57:35AM +0900, HATAYAMA Daisuke wrote:
>> The reasons why we don't allocate ELF note segment in the 1st kernel
>> (old memory) on page boundary is to keep backward compatibility for
>> old kernels, and that if doing so, we waste not a little memory due to
>> round-up operation to fit the memory to page boundary since most of
>> the buffers are in per-cpu area.
>>
>> ELF notes are per-cpu, so total size of ELF note segments depends on
>> number of CPUs. The current maximum number of CPUs on x86_64 is 5192,
>> and there's already system with 4192 CPUs in SGI, where total size
>> amounts to 1MB. This can be larger in the near future or possibly even
>> now on another architecture that has larger size of note per a single
>> cpu. Thus, to avoid the case where memory allocation for large block
>> fails, we allocate vmcore objects on vmalloc memory.
>>
>> This patch adds elfnotesegbuf and elfnotesegbuf_sz variables to keep
>> pointer to the ELF note segment buffer and its size. There's no longer
>> the vmcore object that corresponds to the ELF note segment in
>> vmcore_list. Accordingly, read_vmcore() has new case for ELF note
>> segment and set_vmcore_list_offsets_elf{64,32}() and other helper
>> functions starts calculating offset from sum of size of ELF headers
>> and size of ELF note segment.
>>
>> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
>> ---
>>
>>   fs/proc/vmcore.c |  225 ++++++++++++++++++++++++++++++++++++++++--------------
>>   1 files changed, 165 insertions(+), 60 deletions(-)
>>
>> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
>> index 48886e6..795efd2 100644
>> --- a/fs/proc/vmcore.c
>> +++ b/fs/proc/vmcore.c
>> @@ -34,6 +34,9 @@ static char *elfcorebuf;
>>   static size_t elfcorebuf_sz;
>>   static size_t elfcorebuf_sz_orig;
>>
>> +static char *elfnotesegbuf;
>> +static size_t elfnotesegbuf_sz;
>
> How about calling these just elfnotes_buf and elfnotes_sz.
>
> [..]
>> +/* Merges all the PT_NOTE headers into one. */
>> +static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
>> +					   char **notesegptr, size_t *notesegsz,
>> +					   struct list_head *vc_list)
>> +{
>> +	int i, nr_ptnote=0, rc=0;
>> +	char *tmp;
>> +	Elf64_Ehdr *ehdr_ptr;
>> +	Elf64_Phdr phdr;
>> +	u64 phdr_sz = 0, note_off;
>> +	struct vm_struct *vm;
>> +
>> +	ehdr_ptr = (Elf64_Ehdr *)elfptr;
>> +
>> +	/* The first path calculates the number of PT_NOTE entries and
>> +	 * total size of ELF note segment. */
>> +	rc = process_note_headers_elf64(ehdr_ptr, &nr_ptnote, &phdr_sz, NULL);
>> +	if (rc < 0)
>> +		return rc;
>> +
>> +	*notesegsz = roundup(phdr_sz, PAGE_SIZE);
>> +	*notesegptr = vzalloc(*notesegsz);
>> +	if (!*notesegptr)
>> +		return -ENOMEM;
>> +
>> +	vm = find_vm_area(*notesegptr);
>> +	BUG_ON(!vm);
>> +	vm->flags |= VM_USERMAP;
>> +
>> +	/* The second path copies the ELF note segment in the ELF note
>> +	 * segment buffer. */
>> +	rc = process_note_headers_elf64(ehdr_ptr, NULL, NULL, *notesegptr);
>
> So same function process_note_headers_elf64() is doing two different
> things based on parameters passed. Please create two new functions
> to do two different things and name these appropriately.
>
> Say
>
> get_elf_note_number_and_size()
> copy_elf_notes()

I see. Similar to other functions, 32-bit and 64-bit versions are 
needed. So I give them symbols:

get_note_number_and_size_elf64()
copy_notes_elf64()

and elf32 counterpart.

>
>
>> +	if (rc < 0)
>> +		return rc;
>> +
>>   	/* Prepare merged PT_NOTE program header. */
>>   	phdr.p_type    = PT_NOTE;
>>   	phdr.p_flags   = 0;
>> @@ -304,23 +364,18 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
>>   	return 0;
>>   }
>>
>> -/* Merges all the PT_NOTE headers into one. */
>> -static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
>> -						struct list_head *vc_list)
>> +static int __init process_note_headers_elf32(const Elf32_Ehdr *ehdr_ptr,
>> +					     int *nr_ptnotep, u64 *phdr_szp,
>> +					     char *notesegp)
>
> Can you please describe function parameters at the beginning of function
> in a comment. Things are gettting little confusing now.
>
> What does notesegp signify? phdr_szp could be simply *phdr_sz,
> nr_ptnotesp could be *nr_notes. Please simplify the naming a bit.
> Seems too twisted to me.

I see. I'll reflect that in addition to your other comments.

-- 
Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
