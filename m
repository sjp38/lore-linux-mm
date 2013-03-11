Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id A484A6B0006
	for <linux-mm@kvack.org>; Mon, 11 Mar 2013 18:18:06 -0400 (EDT)
Received: by mail-da0-f54.google.com with SMTP id p1so998930dad.41
        for <linux-mm@kvack.org>; Mon, 11 Mar 2013 15:18:05 -0700 (PDT)
Message-ID: <513E5807.2060303@gmail.com>
Date: Tue, 12 Mar 2013 06:17:43 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2, part1 01/29] mm: introduce common help functions to
 deal with reserved/managed pages
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com> <1362896833-21104-2-git-send-email-jiang.liu@huawei.com> <CAMuHMdXLEkKVfhPu-MfBE37SuHDoVtrEG92PZq2-nD3xw6GNQw@mail.gmail.com>
In-Reply-To: <CAMuHMdXLEkKVfhPu-MfBE37SuHDoVtrEG92PZq2-nD3xw6GNQw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, Anatolij Gustschin <agust@denx.de>, Aurelien Jacquiot <a-jacquiot@ti.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Chen Liqin <liqin.chen@sunplusct.com>, Chris Metcalf <cmetcalf@tilera.com>, Chris Zankel <chris@zankel.net>, David Howells <dhowells@redhat.com>, "David S. Miller" <davem@davemloft.net>, Eric Biederman <ebiederm@xmission.com>, Fenghua Yu <fenghua.yu@intel.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Heiko Carstens <heiko.carstens@de.ibm.com>, Helge Deller <deller@gmx.de>, James Hogan <james.hogan@imgtec.com>, Hirokazu Takata <takata@linux-m32r.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jonas Bonn <jonas@southpole.se>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Lennox Wu <lennox.wu@gmail.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Simek <monstr@monstr.eu>, Michel Lespinasse <walken@google.com>, Mikael Starvik <starvik@axis.com>, Mike Frysinger <vapier@gentoo.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>, Ralf Baechle <ralf@linux-mips.org>, Richard Henderson <rth@twiddle.net>, Rik van Riel <riel@redhat.com>, Russell King <linux@arm.linux.org.uk>, Rusty Russell <rusty@rustcorp.com.au>, Sam Ravnborg <sam@ravnborg.org>, Tang Chen <tangchen@cn.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, x86@kernel.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Vineet Gupta <vgupta@synopsys.com>, linux-snps-arc@vger.kernel.org, virtualization@lists.linux-foundation.org

Hi Geert,
	Thanks for review!

On 03/10/2013 05:20 PM, Geert Uytterhoeven wrote:
> On Sun, Mar 10, 2013 at 7:26 AM, Jiang Liu <liuj97@gmail.com> wrote:
>> Code to deal with reserved/managed pages are duplicated by many
>> architectures, so introduce common help functions to reduce duplicated
>> code. These common help functions will also be used to concentrate code
>> to modify totalram_pages and zone->managed_pages, which makes the code
>> much more clear.
>>
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> 
> I have a few minor comments (see below), but apart from that:
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
> 
>> ---
>>  include/linux/mm.h |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
>>  mm/page_alloc.c    |   20 ++++++++++++++++++++
>>  2 files changed, 68 insertions(+)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 7acc9dc..d75c14b 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1295,6 +1295,54 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
>>                 unsigned long zone_start_pfn, unsigned long *zholes_size);
>>  extern void free_initmem(void);
>>
>> +/*
>> + * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
>> + * into the buddy system. The freed pages will be poisoned with pattern
>> + * "poison" if it's non-zero.
> 
> What if you want to poison with zero?
> As poison is a full int, but memset only uses the least-significant
> byte, you can
> change it to poison if it's positive (i.e. >= 0)?
Good point, ARM64 does poison memory with 0. Will implement that way in next version.

> 
>> +/*
>> + * Default method to free all the __init memory into the buddy system.
>> + * The freed pages will be poisoned with pattern "poison" if it is
>> + * non-zero. Return pages freed into the buddy system.
>> + */
>> +static inline unsigned long free_initmem_default(int poison)
>> +{
>> +       extern char __init_begin[], __init_end[];
>> +
>> +       return free_reserved_area(PAGE_ALIGN((unsigned long)&__init_begin) ,
>> +                                 ((unsigned long)&__init_end) & PAGE_MASK,
> 
> The "PAGE_ALIGN(...)" and "& PAGE_MASK" are superfluous, as
> free_reserved_area() already does that.
Will remove the redundant ops next version.

> 
>> +                                 poison, "unused kernel");
>> +}
>> +
> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 8fcced7..0fadb09 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5113,6 +5113,26 @@ early_param("movablecore", cmdline_parse_movablecore);
>>
>>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>>
>> +unsigned long free_reserved_area(unsigned long start, unsigned long end,
>> +                                int poison, char *s)
>> +{
> 
>> +       if (pages && s)
>> +               pr_info("Freeing %s memory: %ldK (%lx - %lx)\n",
> 
> "%luKiB (0x%lx - 0x%lx)"?
Sure.

Regards!
Gerry

> 
>> +                       s, pages << (PAGE_SHIFT - 10), start, end);
>> +
>> +       return pages;
>> +}
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
