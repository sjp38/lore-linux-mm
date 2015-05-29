Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id D6C636B007B
	for <linux-mm@kvack.org>; Fri, 29 May 2015 14:20:01 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so22996773wic.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 11:20:01 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id y7si4933308wij.68.2015.05.29.11.19.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 11:19:58 -0700 (PDT)
Received: by wivl4 with SMTP id l4so25270335wiv.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 11:19:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1432911782.23540.55.camel@misato.fc.hp.com>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
	<1432739944-22633-13-git-send-email-toshi.kani@hp.com>
	<20150529091129.GC31435@pd.tnic>
	<CAPcyv4jHbrUP7bDpw2Cja5x0eMQZBLmmzFXbotQWSEkAiL1s7Q@mail.gmail.com>
	<1432911782.23540.55.camel@misato.fc.hp.com>
Date: Fri, 29 May 2015 11:19:57 -0700
Message-ID: <CAPcyv4g+zYFkEYpa0HCh0Q+2C3wWNr6v3ZU143h52OKf=U=Qvw@mail.gmail.com>
Subject: Re: [PATCH v10 12/12] drivers/block/pmem: Map NVDIMM with ioremap_wt()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Borislav Petkov <bp@alien8.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, jgross@suse.com, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, hmh@hmh.eng.br, yigal@plexistor.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "Elliott, Robert (Server Storage)" <Elliott@hp.com>, mcgrof@suse.com, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@linux.intel.com>

On Fri, May 29, 2015 at 8:03 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> On Fri, 2015-05-29 at 07:43 -0700, Dan Williams wrote:
>> On Fri, May 29, 2015 at 2:11 AM, Borislav Petkov <bp@alien8.de> wrote:
>> > On Wed, May 27, 2015 at 09:19:04AM -0600, Toshi Kani wrote:
>> >> The pmem driver maps NVDIMM with ioremap_nocache() as we cannot
>> >> write back the contents of the CPU caches in case of a crash.
>> >>
>> >> This patch changes to use ioremap_wt(), which provides uncached
>> >> writes but cached reads, for improving read performance.
>> >>
>> >> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
>> >> ---
>> >>  drivers/block/pmem.c |    4 ++--
>> >>  1 file changed, 2 insertions(+), 2 deletions(-)
>> >>
>> >> diff --git a/drivers/block/pmem.c b/drivers/block/pmem.c
>> >> index eabf4a8..095dfaa 100644
>> >> --- a/drivers/block/pmem.c
>> >> +++ b/drivers/block/pmem.c
>> >> @@ -139,11 +139,11 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
>> >>       }
>> >>
>> >>       /*
>> >> -      * Map the memory as non-cachable, as we can't write back the contents
>> >> +      * Map the memory as write-through, as we can't write back the contents
>> >>        * of the CPU caches in case of a crash.
>> >>        */
>> >>       err = -ENOMEM;
>> >> -     pmem->virt_addr = ioremap_nocache(pmem->phys_addr, pmem->size);
>> >> +     pmem->virt_addr = ioremap_wt(pmem->phys_addr, pmem->size);
>> >>       if (!pmem->virt_addr)
>> >>               goto out_release_region;
>> >
>> > Dan, Ross, what about this one?
>> >
>> > ACK to pick it up as a temporary solution?
>>
>> I see that is_new_memtype_allowed() is updated to disallow some
>> combinations, but the manual seems to imply any mixing of memory types
>> is unsupported.  Which worries me even in the current code where we
>> have uncached mappings in the driver, and potentially cached DAX
>> mappings handed out to userspace.
>
> is_new_memtype_allowed() is not to allow some combinations of mixing of
> memory types.  When it is allowed, the requested type of ioremap_xxx()
> is changed to match with the existing map type, so that mixing of memory
> types does not happen.

Yes, but now if the caller was expecting one memory type and gets
another one that is something I think the driver would want to know.
At a minimum I don't think we want to get emails about pmem driver
performance problems when someone's platform is silently degrading WB
to UC for example.

> DAX uses vm_insert_mixed(), which does not even check the existing map
> type to the physical address.

Right, I think that's a problem...

>> A general quibble separate from this patch is that we don't have a way
>> of knowing if ioremap() will reject or change our requested memory
>> type.  Shouldn't the driver be explicitly requesting a known valid
>> type in advance?
>
> I agree we need a solution here.
>
>> Lastly we now have the PMEM API patches from Ross out for review where
>> he is assuming cached mappings with non-temporal writes:
>> https://lists.01.org/pipermail/linux-nvdimm/2015-May/000929.html.
>> This gives us WC semantics on writes which I believe has the nice
>> property of reducing the number of write transactions to memory.
>> Also, the numbers in the paper seem to be assuming DAX operation, but
>> this ioremap_wt() is in the driver and typically behind a file system.
>> Are the numbers relevant to that usage mode?
>
> I have not looked into the Ross's changes yet, but they do not seem to
> replace the use of ioremap_nocache().  If his changes can use WB type
> reliably, yes, we do not need a temporary solution of using ioremap_wt()
> in this driver.

Hmm, yes you're right, it seems those patches did not change the
implementation to use ioremap_cache()... which happens to not be
implemented on all architectures.  I'll take a look.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
