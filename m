Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id EDDDE6B00A7
	for <linux-mm@kvack.org>; Fri, 29 May 2015 17:46:42 -0400 (EDT)
Received: by lagv1 with SMTP id v1so65243534lag.3
        for <linux-mm@kvack.org>; Fri, 29 May 2015 14:46:42 -0700 (PDT)
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com. [209.85.215.46])
        by mx.google.com with ESMTPS id aa12si5744032lbd.30.2015.05.29.14.46.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 14:46:41 -0700 (PDT)
Received: by lagv1 with SMTP id v1so65243228lag.3
        for <linux-mm@kvack.org>; Fri, 29 May 2015 14:46:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <94D0CD8314A33A4D9D801C0FE68B40295A92F392@G9W0745.americas.hpqcorp.net>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
 <1432739944-22633-13-git-send-email-toshi.kani@hp.com> <20150529091129.GC31435@pd.tnic>
 <CAPcyv4jHbrUP7bDpw2Cja5x0eMQZBLmmzFXbotQWSEkAiL1s7Q@mail.gmail.com>
 <1432911782.23540.55.camel@misato.fc.hp.com> <CAPcyv4g+zYFkEYpa0HCh0Q+2C3wWNr6v3ZU143h52OKf=U=Qvw@mail.gmail.com>
 <CALCETrXXfujebOemesBtgKCkmRTOQFGjdcxjFDF+_P_tv+C0bw@mail.gmail.com> <94D0CD8314A33A4D9D801C0FE68B40295A92F392@G9W0745.americas.hpqcorp.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 29 May 2015 14:46:19 -0700
Message-ID: <CALCETrXhNsk9yX=gerxqHCR6+CLdCGrjt9pDk98yeF0L7yyPvg@mail.gmail.com>
Subject: Re: [PATCH v10 12/12] drivers/block/pmem: Map NVDIMM with ioremap_wt()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Server Storage)" <Elliott@hp.com>
Cc: Dan Williams <dan.j.williams@intel.com>, "Kani, Toshimitsu" <toshi.kani@hp.com>, Borislav Petkov <bp@alien8.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Luis Rodriguez <mcgrof@suse.com>, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@linux.intel.com>

On Fri, May 29, 2015 at 2:29 PM, Elliott, Robert (Server Storage)
<Elliott@hp.com> wrote:
>> -----Original Message-----
>> From: Andy Lutomirski [mailto:luto@amacapital.net]
>> Sent: Friday, May 29, 2015 1:35 PM
> ...
>> Whoa, there!  Why would we use non-temporal stores to WB memory to
>> access persistent memory?  I can see two reasons not to:
>
> Data written to a block storage device (here, the NVDIMM) is unlikely
> to be read or written again any time soon.  It's not like the code
> and data that a program has in memory, where there might be a loop
> accessing the location every CPU clock; it's storage I/O to
> historically very slow (relative to the CPU clock speed) devices.
> The source buffer for that data might be frequently accessed,
> but not the NVDIMM storage itself.
>
> Non-temporal stores avoid wasting cache space on these "one-time"
> accesses.  The same applies for reads and non-temporal loads.
> Keep the CPU data cache lines free for the application.
>
> DAX and mmap() do change that; the application is now free to
> store frequently accessed data structures directly in persistent
> memory.  But, that's not available if btt is used, and
> application loads and stores won't go through the memcpy()
> calls inside pmem anyway.  The non-temporal instructions are
> cache coherent, so data integrity won't get confused by them
> if I/O going through pmem's block storage APIs happens
> to overlap with the application's mmap() regions.
>

You answered the wrong question. :)  I understand the point of the
non-temporal stores -- I don't understand the point of using
non-temporal stores to *WB memory*.  I think we should be okay with
having the kernel mapping use WT instead.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
