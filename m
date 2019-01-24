Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 038FC8E0089
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 09:13:46 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c18so2314441edt.23
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 06:13:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 33sor25742581edr.16.2019.01.24.06.13.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 06:13:44 -0800 (PST)
Date: Thu, 24 Jan 2019 14:13:41 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: cleanup usemap_size() when SPARSEMEM is
 not set
Message-ID: <20190124141341.au6a7jpwccez5vc7@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190118234905.27597-1-richard.weiyang@gmail.com>
 <20190122085524.GE4087@dhcp22.suse.cz>
 <20190122150717.llf4owk6soejibov@master>
 <20190122151628.GI4087@dhcp22.suse.cz>
 <20190122155628.eu4sxocyjb5lrcla@master>
 <20190123095503.GR4087@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190123095503.GR4087@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Wed, Jan 23, 2019 at 10:55:03AM +0100, Michal Hocko wrote:
>On Tue 22-01-19 15:56:28, Wei Yang wrote:
>> 
>> I think the answer is yes.
>> 
>>   * it reduce the code from 6 lines to 3 lines, 50% off
>>   * by reducing calculation back and forth, it would be easier for
>>     audience to catch what it tries to do
>
>To be honest, I really do not see this sufficient to justify touching
>the code unless the resulting _generated_ code is better/more efficient.

Tried objdump to compare two version.

               Base       Patched      Reduced
Code Size(B)   48         39           18.7%
Instructions   12         10           16.6%

Here is the raw output.

00000000000001be <usemap_size_ywtest1>:
{
 1be:	e8 00 00 00 00       	callq  1c3 <usemap_size_ywtest1+0x5>
	zonesize += zone_start_pfn & (pageblock_nr_pages-1);
 1c3:	81 e7 ff 01 00 00    	and    $0x1ff,%edi
{
 1c9:	55                   	push   %rbp
	return usemapsize / 8;
 1ca:	48 ba f8 ff ff ff ff 	movabs $0x1ffffffffffffff8,%rdx
 1d1:	ff ff 1f 
	usemapsize = roundup(zonesize, pageblock_nr_pages);
 1d4:	48 8d 84 3e ff 01 00 	lea    0x1ff(%rsi,%rdi,1),%rax
 1db:	00 
	usemapsize *= NR_PAGEBLOCK_BITS;
 1dc:	48 c1 e8 09          	shr    $0x9,%rax
	usemapsize = roundup(usemapsize, 8 * sizeof(unsigned long));
 1e0:	48 8d 04 85 3f 00 00 	lea    0x3f(,%rax,4),%rax
 1e7:	00 
{
 1e8:	48 89 e5             	mov    %rsp,%rbp
}
 1eb:	5d                   	pop    %rbp
	return usemapsize / 8;
 1ec:	48 c1 e8 03          	shr    $0x3,%rax
 1f0:	48 21 d0             	and    %rdx,%rax
}
 1f3:	c3                   	retq   

00000000000001f4 <usemap_size_ywtest2>:
{
 1f4:	e8 00 00 00 00       	callq  1f9 <usemap_size_ywtest2+0x5>
	zonesize += zone_start_pfn & (pageblock_nr_pages-1);
 1f9:	81 e7 ff 01 00 00    	and    $0x1ff,%edi
{
 1ff:	55                   	push   %rbp
	usemapsize = DIV_ROUND_UP(zonesize, pageblock_nr_pages);
 200:	48 8d 84 3e ff 01 00 	lea    0x1ff(%rsi,%rdi,1),%rax
 207:	00 
 208:	48 c1 e8 09          	shr    $0x9,%rax
	return BITS_TO_LONGS(usemapsize) * sizeof(unsigned long);
 20c:	48 8d 04 85 3f 00 00 	lea    0x3f(,%rax,4),%rax
 213:	00 
{
 214:	48 89 e5             	mov    %rsp,%rbp
}
 217:	5d                   	pop    %rbp
	return BITS_TO_LONGS(usemapsize) * sizeof(unsigned long);
 218:	48 c1 e8 06          	shr    $0x6,%rax
 21c:	48 c1 e0 03          	shl    $0x3,%rax
}
 220:	c3                   	retq   


-- 
Wei Yang
Help you, Help me


>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
