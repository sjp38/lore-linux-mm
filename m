Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id D6DCE6B00AC
	for <linux-mm@kvack.org>; Fri, 29 May 2015 18:34:17 -0400 (EDT)
Received: by pacux9 with SMTP id ux9so27998203pac.3
        for <linux-mm@kvack.org>; Fri, 29 May 2015 15:34:17 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id on7si10294783pdb.188.2015.05.29.15.34.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 15:34:17 -0700 (PDT)
In-Reply-To: <CALCETrXhNsk9yX=gerxqHCR6+CLdCGrjt9pDk98yeF0L7yyPvg@mail.gmail.com>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com> <1432739944-22633-13-git-send-email-toshi.kani@hp.com> <20150529091129.GC31435@pd.tnic> <CAPcyv4jHbrUP7bDpw2Cja5x0eMQZBLmmzFXbotQWSEkAiL1s7Q@mail.gmail.com> <1432911782.23540.55.camel@misato.fc.hp.com> <CAPcyv4g+zYFkEYpa0HCh0Q+2C3wWNr6v3ZU143h52OKf=U=Qvw@mail.gmail.com> <CALCETrXXfujebOemesBtgKCkmRTOQFGjdcxjFDF+_P_tv+C0bw@mail.gmail.com> <94D0CD8314A33A4D9D801C0FE68B40295A92F392@G9W0745.americas.hpqcorp.net> <CALCETrXhNsk9yX=gerxqHCR6+CLdCGrjt9pDk98yeF0L7yyPvg@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [PATCH v10 12/12] drivers/block/pmem: Map NVDIMM with ioremap_wt()
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Fri, 29 May 2015 15:32:59 -0700
Message-ID: <126375CE-37E2-4406-B4E8-3C991F02A0C1@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, "Elliott, Robert (Server Storage)" <Elliott@hp.com>
Cc: Dan Williams <dan.j.williams@intel.com>, "Kani, Toshimitsu" <toshi.kani@hp.com>, Borislav Petkov <bp@alien8.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Luis Rodriguez <mcgrof@suse.com>, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@linux.intel.com>

Nontemporal stores to WB memory is fine in such a way that it doesn't pollute the cache.  This can be done by denoting to WC or by forcing cache allocation out of only a subset of the cache.

On May 29, 2015 2:46:19 PM PDT, Andy Lutomirski <luto@amacapital.net> wrote:
>On Fri, May 29, 2015 at 2:29 PM, Elliott, Robert (Server Storage)
><Elliott@hp.com> wrote:
>>> -----Original Message-----
>>> From: Andy Lutomirski [mailto:luto@amacapital.net]
>>> Sent: Friday, May 29, 2015 1:35 PM
>> ...
>>> Whoa, there!  Why would we use non-temporal stores to WB memory to
>>> access persistent memory?  I can see two reasons not to:
>>
>> Data written to a block storage device (here, the NVDIMM) is unlikely
>> to be read or written again any time soon.  It's not like the code
>> and data that a program has in memory, where there might be a loop
>> accessing the location every CPU clock; it's storage I/O to
>> historically very slow (relative to the CPU clock speed) devices.
>> The source buffer for that data might be frequently accessed,
>> but not the NVDIMM storage itself.
>>
>> Non-temporal stores avoid wasting cache space on these "one-time"
>> accesses.  The same applies for reads and non-temporal loads.
>> Keep the CPU data cache lines free for the application.
>>
>> DAX and mmap() do change that; the application is now free to
>> store frequently accessed data structures directly in persistent
>> memory.  But, that's not available if btt is used, and
>> application loads and stores won't go through the memcpy()
>> calls inside pmem anyway.  The non-temporal instructions are
>> cache coherent, so data integrity won't get confused by them
>> if I/O going through pmem's block storage APIs happens
>> to overlap with the application's mmap() regions.
>>
>
>You answered the wrong question. :)  I understand the point of the
>non-temporal stores -- I don't understand the point of using
>non-temporal stores to *WB memory*.  I think we should be okay with
>having the kernel mapping use WT instead.
>
>--Andy

-- 
Sent from my mobile phone.  Please pardon brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
