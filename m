Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 7FE506B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 21:57:17 -0400 (EDT)
Message-ID: <516375DF.3080602@cn.fujitsu.com>
Date: Tue, 09 Apr 2013 09:58:55 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] mm: vmemmap: add vmemmap_verify check for hot-add
 node/memory case
References: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com> <CAE9FiQVaByGOTjLVthRkEze_ekXm5LAKgKdHzrD+q1iYmjgZFQ@mail.gmail.com> <20130408135553.2f60518d923b6920bdf1931f@linux-foundation.org>
In-Reply-To: <20130408135553.2f60518d923b6920bdf1931f@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yinghai Lu <yinghai@kernel.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, will.deacon@arm.com, Arnd Bergmann <arnd@arndb.de>, tony@atomide.com, Ben Hutchings <ben@decadent.org.uk>, linux-arm-kernel@lists.infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Hi Andrew,

On 04/09/2013 04:55 AM, Andrew Morton wrote:
> On Mon, 8 Apr 2013 11:40:11 -0700 Yinghai Lu <yinghai@kernel.org> wrote:
> 
>> On Mon, Apr 8, 2013 at 2:56 AM, Lin Feng <linfeng@cn.fujitsu.com> wrote:
>>> In hot add node(memory) case, vmemmap pages are always allocated from other
>>> node,
>>
>> that is broken, and should be fixed.
>> vmemmap should be on local node even for hot add node.
>>
> 
> That would be nice.
> 
> I don't see much value in the added warnings, really.  Because there's
> nothing the user can *do* about them, apart from a) stop using NUMA, b)
> stop using memory hotplug, c) become a kernel MM developer or d) switch
> to Windows.
> 
> 

I agree that we can't do anything helpful to response to such warnings for
the moment, but maybe someone can at least take your c) measure if it's 
what he really cares. ;-)

This patch sent because we found that on a old kernel we get such warnings
but we don't on latest kernel, it appears that it has been fixed by someone
but in fact it is due to sizeof(struct page) is 64bytes aligned now but not
on the old kernel. Now the struct pages for a section is always 2MB in size, 
every time we populate vmemmap for a section we get a new pmd, so the 
vmemmap_verify() check is just ignored. Such phenomenon is misleading.

struct page {
	...
}
#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
      __aligned(2 * sizeof(unsigned long))
#endif
; 

Anyway the current logic for vmemmap_verify() is broken :(

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
