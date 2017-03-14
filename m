Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 552A86B038B
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:12:35 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v66so51575944wrc.4
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 09:12:35 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Date: Tue, 14 Mar 2017 09:12:29 -0700
Subject: Re: [RFC PATCH 00/13] Introduce first class virtual address spaces
Message-ID: <20170314161229.tl6hsmian2gdep47@arch-dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALCETrXKvNWv1OtoSo_HWf5ZHSvyGS1NsuQod6Zt+tEg3MT5Sg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Till Smejkal <till.smejkal@googlemail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-alpha@vger.kernel.org, arcml <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-metag@vger.kernel.org, Linux MIPS Mailing List <linux-mips@linux-mips.org>, linux-parisc@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, Linux Media Mailing List <linux-media@vger.kernel.org>, linux-mtd@lists.infradead.org, USB list <linux-usb@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-aio@kvack.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, ALSA development <alsa-devel@alsa-project.org>

On Mon, 13 Mar 2017, Andy Lutomirski wrote:
> On Mon, Mar 13, 2017 at 7:07 PM, Till Smejkal
> <till.smejkal@googlemail.com> wrote:
> > On Mon, 13 Mar 2017, Andy Lutomirski wrote:
> >> This sounds rather complicated.  Getting TLB flushing right seems
> >> tricky.  Why not just map the same thing into multiple mms?
> >
> > This is exactly what happens at the end. The memory region that is described by the
> > VAS segment will be mapped in the ASes that use the segment.
> 
> So why is this kernel feature better than just doing MAP_SHARED
> manually in userspace?

One advantage of VAS segments is that they can be globally queried by user programs
which means that VAS segments can be shared by applications that not necessarily have
to be related. If I am not mistaken, MAP_SHARED of pure in memory data will only work
if the tasks that share the memory region are related (aka. have a common parent that
initialized the shared mapping). Otherwise, the shared mapping have to be backed by a
file. VAS segments on the other side allow sharing of pure in memory data by
arbitrary related tasks without the need of a file. This becomes especially
interesting if one combines VAS segments with non-volatile memory since one can keep
data structures in the NVM and still be able to share them between multiple tasks.

> >> Ick.  Please don't do this.  Can we please keep an mm as just an mm
> >> and not make it look magically different depending on which process
> >> maps it?  If you need a trampoline (which you do, of course), just
> >> write a trampoline in regular user code and map it manually.
> >
> > Did I understand you correctly that you are proposing that the switching thread
> > should make sure by itself that its code, stack, a?| memory regions are properly setup
> > in the new AS before/after switching into it? I think, this would make using first
> > class virtual address spaces much more difficult for user applications to the extend
> > that I am not even sure if they can be used at all. At the moment, switching into a
> > VAS is a very simple operation for an application because the kernel will just simply
> > do the right thing.
> 
> Yes.  I think that having the same mm_struct look different from
> different tasks is problematic.  Getting it right in the arch code is
> going to be nasty.  The heuristics of what to share are also tough --
> why would text + data + stack or whatever you're doing be adequate?
> What if you're in a thread?  What if two tasks have their stacks in
> the same place?

The different ASes that a task now can have when it uses first class virtual address
spaces are not realized in the kernel by using only one mm_struct per task that just
looks differently but by using multiple mm_structs - one for each AS that the task
can execute in. When a task attaches a first class virtual address space to itself to
be able to use another AS, the kernel adds a temporary mm_struct to this task that
contains the mappings of the first class virtual address space and the one shared
with the task's original AS. If a thread now wants to switch into this attached first
class virtual address space the kernel only changes the 'mm' and 'active_mm' pointers
in the task_struct of the thread to the temporary mm_struct and performs the
corresponding mm_switch operation. The original mm_struct of the thread will not be
changed.

Accordingly, I do not magically make mm_structs look differently depending on the
task that uses it, but create temporary mm_structs that only contain mappings to the
same memory regions.

I agree that finding a good heuristics of what to share is difficult. At the moment,
all memory regions that are available in the task's original AS will also be
available when a thread switches into an attached first class virtual address space
(aka. are shared). That means that VAS can mainly be used to extend the AS of a task
in the current state of the implementation. The reason why I implemented the sharing
in this way is that I didn't want to break shared libraries. If I only share
code+heap+stack, shared libraries would not work anymore after switching into a VAS.

> I could imagine something like a sigaltstack() mode that lets you set
> a signal up to also switch mm could be useful.

This is a very interesting idea. I will keep it in mind for future use cases of
multiple virtual address spaces per task.

Thanks
Till

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
