Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id E62F96B024F
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 15:23:24 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4960604pbb.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 12:23:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120622185113.GK4642@google.com>
References: <20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
	<1339667440.3321.7.camel@lappy>
	<20120618223203.GE32733@google.com>
	<1340059850.3416.3.camel@lappy>
	<20120619041154.GA28651@shangw>
	<20120619212059.GJ32733@google.com>
	<20120619212618.GK32733@google.com>
	<CAE9FiQVECyRBie-kgBETmqxPaMx24kUt1W07qAqoGD4vNus5xQ@mail.gmail.com>
	<20120621201728.GB4642@google.com>
	<CAE9FiQXubmnKHjnqOxVeoJknJZFNuStCcW=1XC6jLE7eznkTmg@mail.gmail.com>
	<20120622185113.GK4642@google.com>
Date: Fri, 22 Jun 2012 12:23:24 -0700
Message-ID: <CAE9FiQVV+WOWywnanrP7nX-wai=aXmQS1Dcvt4PxJg5XWynC+Q@mail.gmail.com>
Subject: Re: Early boot panic on machine with lots of memory
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jun 22, 2012 at 11:51 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Yinghai.
>>
>> Also I add another patch to double check if there is any reference
>> with reserved.region.
>> so far there is no reference found.
>
> Thanks for checking it. =A0I was worried because of the re-reservation
> of reserved.regions after giving memory to the page allocator -
> ie. memblock_reserve_reserved_regions() call. =A0If memblock is done at
> that point, there's no reason to have that call at all. =A0It could be
> that that's just dead code. =A0If so, why aren't we freeing
> memory.regions?

During converting bootmem to use early_res stage, I still kept the
numa handling.
like one node by one node. So need to put the reserved.regions back.
Later found we could do that for all node at the same time.

For memory.regions, a little different, at that time I want to kill
e820 all like e820_all_mapped_ram.

Yes, we should get back region that is allocated for doubled memory.regions=
.
but did not trigger that doubling yet.

Also for x86, all memblock in __initdata, and will be freed later.

> Also, shouldn't we be clearing
> memblock.cnt/max/total_size/regions so that we know for sure that it's
> never used again? =A0What am I missing?

64bit mem_init(), after absent_page_in_range(), will not need memblock anym=
ore.
  --- absent_page_in_range will refer for_each_mem_pfn_range.

so after that could clear that for memory.regions too.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
