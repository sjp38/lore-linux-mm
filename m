Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 17CF86B0396
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 15:54:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 77so367561870pgc.5
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:54:13 -0700 (PDT)
Subject: Re: [RFC PATCH 00/13] Introduce first class virtual address spaces
References: <20170314161229.tl6hsmian2gdep47@arch-dev>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <8d9333d6-2f81-a9de-484e-e1d655e1d3c3@mellanox.com>
Date: Tue, 14 Mar 2017 15:53:44 -0400
MIME-Version: 1.0
In-Reply-To: <20170314161229.tl6hsmian2gdep47@arch-dev>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Andy Lutomirski <luto@kernel.org>, Till Smejkal <till.smejkal@googlemail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J.
 Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-alpha@vger.kernel.org, arcml <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-metag@vger.kernel.org, Linux MIPS Mailing List <linux-mips@linux-mips.org>, linux-parisc@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, Linux Media Mailing List <linux-media@vger.kernel.org>, linux-mtd@lists.infradead.org, USB list <linux-usb@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-aio@kvack.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, ALSA development <alsa-devel@alsa-project.org>

On 3/14/2017 12:12 PM, Till Smejkal wrote:
> On Mon, 13 Mar 2017, Andy Lutomirski wrote:
>> On Mon, Mar 13, 2017 at 7:07 PM, Till Smejkal
>> <till.smejkal@googlemail.com> wrote:
>>> On Mon, 13 Mar 2017, Andy Lutomirski wrote:
>>>> This sounds rather complicated.  Getting TLB flushing right seems
>>>> tricky.  Why not just map the same thing into multiple mms?
>>> This is exactly what happens at the end. The memory region that is described by the
>>> VAS segment will be mapped in the ASes that use the segment.
>> So why is this kernel feature better than just doing MAP_SHARED
>> manually in userspace?
> One advantage of VAS segments is that they can be globally queried by user programs
> which means that VAS segments can be shared by applications that not necessarily have
> to be related. If I am not mistaken, MAP_SHARED of pure in memory data will only work
> if the tasks that share the memory region are related (aka. have a common parent that
> initialized the shared mapping). Otherwise, the shared mapping have to be backed by a
> file.

True, but why is this bad?  The shared mapping will be memory resident
regardless, even if backed by a file (unless swapped out under heavy
memory pressure, but arguably that's a feature anyway).  More importantly,
having a file name is a simple and consistent way of identifying such
shared memory segments.

With a little work, you can also arrange to map such files into memory
at a fixed address in all participating processes, thus making internal
pointers work correctly.

> VAS segments on the other side allow sharing of pure in memory data by
> arbitrary related tasks without the need of a file. This becomes especially
> interesting if one combines VAS segments with non-volatile memory since one can keep
> data structures in the NVM and still be able to share them between multiple tasks.

I am not fully up to speed on NV/pmem stuff, but isn't that exactly what
the DAX mode is supposed to allow you to do?  If so, isn't sharing a
mapped file on a DAX filesystem on top of pmem equivalent to what
you're proposing?

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
