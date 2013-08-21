Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id A55FB6B00AE
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 11:05:36 -0400 (EDT)
In-Reply-To: <20130821144258.GH2593@phenom.dumpdata.com>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com> <1377080143-28455-6-git-send-email-tangchen@cn.fujitsu.com> <18d71946-6de9-4af2-a6a8-05fae51755af@email.android.com> <68a532f2-e468-4aea-b42b-a444ec079c3f@email.android.com> <20130821144258.GH2593@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH 5/8] x86, brk: Make extend_brk() available with va/pa.
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Wed, 21 Aug 2013 17:04:21 +0200
Message-ID: <025ad747-18b5-4d7a-8eea-9ba8a5b0d53c@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org



Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote:
>On Wed, Aug 21, 2013 at 02:35:36PM +0200, H. Peter Anvin wrote:
>> Global symbols are inaccessible in physical mode.
>
>Even if they are embedded in the assembler code and use
>GLOBAL(paging_enabled) ?

Yes, because the address is different in physical mode.  Think about it.  You could do a *function* like:

paging_enabled:
	mov (%esp),%edx
	xor %eax,%eax
	cmpl $PAGE_OFFSET,%edx
	setae %al
	ret

>> 
>> This is incidentally yet another example of "PV/weird platform
>violence", since in their absence it would be trivial to work around
>this by using segmentation.
>
>I don't follow why it could not.
>
>Why can't there be a __pa_symbol(paging_enabled) that is used. Won't
>that in effect allow you to check the contents of that 'global
>constant' even when you don't have paging enabled?

Yes.  But not once paging has been turned on.

>> >>As mentioned above, on 32bit before paging is enabled, we have to
>> >>access variables
>> >>with pa. So introduce a "bool is_phys" parameter to extend_brk(),
>and
>> >>convert va
>> >>to pa is it is true.
>> >
>> >Could you do it differently? Meaning have a global symbol
>> >(paging_enabled) which will be used by most of the functions you
>> >changed in this patch and the next ones? It would naturally be
>enabled
>> >when paging is on and __va addresses can be used. 
>> >
>> >That could also be used in the printk case to do a BUG_ON before
>paging
>> >is enabled on 32bit. Or perhaps use a different code path to deal
>with
>> >using __pa address. 
>> >
>> >? 

-- 
Sent from my mobile phone. Please excuse brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
