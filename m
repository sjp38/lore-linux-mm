Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 303AE6B0033
	for <linux-mm@kvack.org>; Thu, 16 May 2013 20:08:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 52E7B3EE0BD
	for <linux-mm@kvack.org>; Fri, 17 May 2013 09:08:29 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 40BB145DEBB
	for <linux-mm@kvack.org>; Fri, 17 May 2013 09:08:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 28D5F45DEB6
	for <linux-mm@kvack.org>; Fri, 17 May 2013 09:08:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 17007E08002
	for <linux-mm@kvack.org>; Fri, 17 May 2013 09:08:29 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0E7F1DB8038
	for <linux-mm@kvack.org>; Fri, 17 May 2013 09:08:28 +0900 (JST)
Message-ID: <519574E8.5020704@jp.fujitsu.com>
Date: Fri, 17 May 2013 09:08:08 +0900
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 2/8] vmcore: allocate buffer for ELF headers on page-size
 alignment
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6> <20130515090551.28109.73350.stgit@localhost6.localdomain6> <20130516165105.GB8726@redhat.com>
In-Reply-To: <20130516165105.GB8726@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

(2013/05/17 1:51), Vivek Goyal wrote:
> On Wed, May 15, 2013 at 06:05:51PM +0900, HATAYAMA Daisuke wrote:
>
> [..]
>> @@ -398,9 +403,7 @@ static int __init process_ptload_program_headers_elf64(char *elfptr,
>>   	phdr_ptr = (Elf64_Phdr*)(elfptr + sizeof(Elf64_Ehdr)); /* PT_NOTE hdr */
>>
>>   	/* First program header is PT_NOTE header. */
>> -	vmcore_off = sizeof(Elf64_Ehdr) +
>> -			(ehdr_ptr->e_phnum) * sizeof(Elf64_Phdr) +
>> -			phdr_ptr->p_memsz; /* Note sections */
>> +	vmcore_off = elfsz + roundup(phdr_ptr->p_memsz, PAGE_SIZE);
>>
>>   	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
>>   		if (phdr_ptr->p_type != PT_LOAD)
>> @@ -435,9 +438,7 @@ static int __init process_ptload_program_headers_elf32(char *elfptr,
>>   	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr)); /* PT_NOTE hdr */
>>
>>   	/* First program header is PT_NOTE header. */
>> -	vmcore_off = sizeof(Elf32_Ehdr) +
>> -			(ehdr_ptr->e_phnum) * sizeof(Elf32_Phdr) +
>> -			phdr_ptr->p_memsz; /* Note sections */
>> +	vmcore_off = elfsz + roundup(phdr_ptr->p_memsz, PAGE_SIZE);
>
> Hmm.., so we are rounding up ELF note data size too here. I think this belongs
> in some other patch as in this patch we are just rounding up the elf
> headers.
>
> This might create read problems too as we have not taking care of this
> rounding when adding note to vc_list and it might happen that we are
> reading wrong data at a particular offset.
>
> So may be this rounding up we should do in later patches when we take
> care of copying ELF notes data to second kernel.
>
> Vivek
>

This is my careless fault. They should have been in 6/7.

-- 
Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
