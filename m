Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 1926B6B0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 12:35:03 -0500 (EST)
Date: Wed, 6 Mar 2013 17:21:41 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC PATCH v1 01/33] mm: introduce common help functions to
	deal with reserved/managed pages
Message-ID: <20130306172140.GS17833@n2100.arm.linux.org.uk>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com> <1362495317-32682-2-git-send-email-jiang.liu@huawei.com> <20130305194722.GA12225@merkur.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130305194722.GA12225@merkur.ravnborg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Jiang Liu <liuj97@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, Anatolij Gustschin <agust@denx.de>, Aurelien Jacquiot <a-jacquiot@ti.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Chen Liqin <liqin.chen@sunplusct.com>, Chris Metcalf <cmetcalf@tilera.com>, Chris Zankel <chris@zankel.net>, David Howells <dhowells@redhat.com>, "David S. Miller" <davem@davemloft.net>, Eric Biederman <ebiederm@xmission.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Heiko Carstens <heiko.carstens@de.ibm.com>, Helge Deller <deller@gmx.de>, Hirokazu Takata <takata@linux-m32r.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jonas Bonn <jonas@southpole.se>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Lennox Wu <lennox.wu@gmail.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Simek <monstr@monstr.eu>, Michel Lespinasse <walken@google.com>, Mikael Starvik <starvik@axis.com>, Mike Frysinger <vapier@gentoo.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>, Ralf Baechle <ralf@linux-mips.org>, Richard Henderson <rth@twiddle.net>, Rik van Riel <riel@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, Tang Chen <tangchen@cn.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, x86@kernel.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, virtualization@lists.linux-foundation.org

On Tue, Mar 05, 2013 at 08:47:22PM +0100, Sam Ravnborg wrote:
> On Tue, Mar 05, 2013 at 10:54:44PM +0800, Jiang Liu wrote:
> > +static inline void free_initmem_default(int poison)
> > +{
> 
> Why request user to supply the poison argumet. If this is the default
> implmentation then use the default poison value too (POISON_FREE_INITMEM)

That poison value is inappropriate on some architectures like ARM - it's
executable.  The default poison value leads to:

   0:	cccccccc 	stclgt	12, cr12, [ip], {204}	; 0xcc

or

   4:	cccc      	ldmia	r4!, {r2, r3, r6, r7}

And we might as well forget using any kind of poison in that case.

The value which use is an undefined instruction on ARM and Thumb.

Notice the calls to poison_init_mem() in arch/arm/mm/init.c, which are
left by these patches, allowing us to continue using an appropriate
architecture specific value which will help to ensure that people
calling discarded init functions get appropriately bitten.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
