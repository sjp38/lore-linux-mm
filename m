Received: by ug-out-1314.google.com with SMTP id 34so2508259ugf.19
        for <linux-mm@kvack.org>; Mon, 01 Dec 2008 06:48:09 -0800 (PST)
Message-ID: <4933F925.3020907@gmail.com>
Date: Mon, 01 Dec 2008 17:48:05 +0300
From: Alexey Starikovskiy <aystarik@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch][rfc] acpi: do not use kmem caches
References: <20081201083128.GB2529@wotan.suse.de>  <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com>  <20081201120002.GB10790@wotan.suse.de>  <4933E2C3.4020400@gmail.com> <1228138641.14439.18.camel@penberg-laptop> <Pine.LNX.4.64.0812010828150.14977@quilx.com>
In-Reply-To: <Pine.LNX.4.64.0812010828150.14977@quilx.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Mon, 1 Dec 2008, Pekka Enberg wrote:
>
>   
>> Why do you think Nick's patch is going to _increase_ memory consumption?
>> SLUB _already_ merges the ACPI caches with kmalloc caches so you won't
>> see any difference there. For SLAB, it's a gain because there's not
>> enough activity going on which results in lots of unused space in the
>> slabs (which is, btw, the reason SLUB does slab merging in the first
>> place).
>>     
>
> The patch is going to increase memory consumption because the use of
> the kmalloc array means that the allocated object sizes are rounded up to
> the next power of two.
>
> I would recommend to keep the caches. Subsystem specific caches help to
> simplify debugging and track the memory allocated for various purposes in
> addition to saving the rounding up to power of two overhead.
> And with SLUB the creation of such caches usually does not require
> additional memory.
>
> Maybe it would be best to avoid kmalloc as much as possible.
>
>   
Christoph,
Thanks for support, these were my thoughts, when I changed ACPICA to use 
kmem_cache instead of
it's own on top of kmalloc 4 years ago...
Here are two acpi caches on my thinkpad z61m, IMHO any laptop will show 
similar numbers:

aystarik@thinkpad:~$ cat /proc/slabinfo | grep Acpi
Acpi-ParseExt       2856   2856     72   56    1 : tunables    0    0    
0 : slabdata     51     51      0
Acpi-Parse           170    170     48   85    1 : tunables    0    0    
0 : slabdata      2      2      0

Size of first will become 96 and size of second will be 64 if kmalloc is 
used, and we don't count ACPICA internal overhead.
Number of used blocks is not smallest in the list of slabs, actually it 
is among the highest.

Regards,
Alex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
