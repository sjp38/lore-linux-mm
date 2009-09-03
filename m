Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 57C1F6B0085
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 22:05:07 -0400 (EDT)
Date: Thu, 3 Sep 2009 10:04:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090903020452.GA9474@localhost>
References: <4A846581.2020304@redhat.com> <20090813211626.GA28274@cmpxchg.org> <4A850F4A.9020507@redhat.com> <20090814091055.GA29338@cmpxchg.org> <20090814095106.GA3345@localhost> <4A856467.6050102@redhat.com> <20090815054524.GB11387@localhost> <9EECC02A4CC333418C00A85D21E89326B6611E81@azsmsx502.amr.corp.intel.com> <20090818022609.GA7958@localhost> <9EECC02A4CC333418C00A85D21E893260184184010@azsmsx502.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9EECC02A4CC333418C00A85D21E893260184184010@azsmsx502.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
To: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Jeff,

On Thu, Sep 03, 2009 at 03:30:59AM +0800, Dike, Jeffrey G wrote:
> I'm trying to better understand the motivation for your
> make-mapped-exec-pages-first-class-citizens patch.  As I read your
> (very detailed!) description, you are diagnosing a threshold effect
> from Rik's evict-use-once-pages-first patch where if the inactive
> list is slightly smaller than the active list, the active list will
> start being scanned, pushing text (and other) pages onto the
> inactive list where they will be quickly kicked out to swap.

Right.

> As I read Rik's patch, if the active list is one page larger than
> the inactive list, then a batch of pages will get moved from one to
> the other.  For this to have a noticeable effect on the system once
> the streaming is done, there must be something continuing to keep
> the active list larger than the inactive list.  Maybe there is a
> consistent percentage of the streamed pages which are use-twice. 

Right. Besides the use-twice case, I also explored the
desktop-working-set-cannot-fit-in-memory case in the patch.

> So, we a threshold effect where a small change in input (the size of
> the streaming file vs the number of active pages) causes a large
> change in output (lots of text pages suddenly start getting thrown
> out).   My immediate reaction to that is that there shouldn't be
> this sudden change in behavior, and that maybe there should only be
> enough scanning in shink_active_list to bring the two lists back to
> parity.  However, if there's something keeping the active list
> bigger than the inactive list, this will just put off the inevitable
> required scanning.

Yes there will be a sudden "behavior change" as soon as active list
grows larger than inactive list.  However the "output change" is
bounded and not as large, because that extra behavior to scan active
list stops as soon as the two lists are back to parity.

> As for your patch, it seems like we have a problem with scanning
> I/O, and instead of looking at those pages, you are looking to
> protect some other set of pages (mapped text).  That, in turn,
> increases pressure on anonymous pages (which is where I came in).
> Wouldn't it be a better idea to keep looking at those streaming
> pages and figure out how to get them out of memory quickly?

The scanning I/O problem has been largely addressed by Rik's patch.
It is not optimal(which is hard), but fair enough for common cases.

Your kvm test case sounds like desktop-working-set-cannot-fit-in-memory.
In that case, it obviously benefits to protect the exec-mapped pages,
and there are not too much kvm exec-mapped pages to impact anon pages.

I ran a kvm and collected its number exec-mapped pages as follows.
They sum up to ~3MB. This is not a big pressure on memory thrashing.

Thanks,
Fengguang
---

Rss of kvm:

% grep -A2 x /proc/7640/smaps | grep -v Size
00400000-005fe000 r-xp 00000000 08:02 1890389                            /usr/bin/kvm
Rss:                 680 kB
--
7f6c029f9000-7f6c02a0f000 r-xp 00000000 08:02 458771                     /lib/libgcc_s.so.1
Rss:                  16 kB
--
7f6c02c10000-7f6c02d00000 r-xp 00000000 08:02 1885409                    /usr/lib/libstdc++.so.6.0.10
Rss:                 364 kB
--
7f6c03bf2000-7f6c03bf7000 r-xp 00000000 08:02 1887873                    /usr/lib/libXdmcp.so.6.0.0
Rss:                  12 kB
--
7f6c03df7000-7f6c03df9000 r-xp 00000000 08:02 1887871                    /usr/lib/libXau.so.6.0.0
Rss:                   8 kB
--
7f6c03ff9000-7f6c04019000 r-xp 00000000 08:02 458890                     /lib/libx86.so.1
Rss:                  36 kB
--
7f6c04019000-7f6c04218000 ---p 00020000 08:02 458890                     /lib/libx86.so.1
Rss:                   0 kB
--
7f6c04218000-7f6c0421a000 rw-p 0001f000 08:02 458890                     /lib/libx86.so.1
Rss:                   8 kB
--
7f6c0421b000-7f6c0421f000 r-xp 00000000 08:02 458861                     /lib/libattr.so.1.1.0
Rss:                  12 kB
--
7f6c0441f000-7f6c04434000 r-xp 00000000 08:02 460739                     /lib/libnsl-2.9.so
Rss:                  24 kB
--
7f6c04637000-7f6c04647000 r-xp 00000000 08:02 1897259                    /usr/lib/libXext.so.6.4.0
Rss:                  20 kB
--
7f6c04647000-7f6c04847000 ---p 00010000 08:02 1897259                    /usr/lib/libXext.so.6.4.0
Rss:                   0 kB
--
7f6c04847000-7f6c04848000 rw-p 00010000 08:02 1897259                    /usr/lib/libXext.so.6.4.0
Rss:                   4 kB
--
7f6c04848000-7f6c04978000 r-xp 00000000 08:02 1889103                    /usr/lib/libicuuc.so.38.1
Rss:                 244 kB
--
7f6c04b89000-7f6c04ba4000 r-xp 00000000 08:02 1886322                    /usr/lib/libxcb.so.1.1.0
Rss:                  28 kB
--
7f6c04ba4000-7f6c04da4000 ---p 0001b000 08:02 1886322                    /usr/lib/libxcb.so.1.1.0
Rss:                   0 kB
--
7f6c04da4000-7f6c04da5000 rw-p 0001b000 08:02 1886322                    /usr/lib/libxcb.so.1.1.0
Rss:                   4 kB
--
7f6c04da5000-7f6c04df3000 r-xp 00000000 08:02 1899899                    /usr/lib/libvga.so.1.4.3
Rss:                  68 kB
--
7f6c05004000-7f6c05018000 r-xp 00000000 08:02 1896343                    /usr/lib/libdirect-1.0.so.0.1.0
Rss:                  24 kB
--
7f6c05219000-7f6c05221000 r-xp 00000000 08:02 1892825                    /usr/lib/libfusion-1.0.so.0.1.0
Rss:                  16 kB
--
7f6c05421000-7f6c0548d000 r-xp 00000000 08:02 1892826                    /usr/lib/libdirectfb-1.0.so.0.1.0
Rss:                  64 kB
--
7f6c05691000-7f6c056a4000 r-xp 00000000 08:02 460720                     /lib/libresolv-2.9.so
Rss:                  20 kB
--
7f6c058a7000-7f6c058aa000 r-xp 00000000 08:02 1895568                    /usr/lib/libgpg-error.so.0.4.0
Rss:                   4 kB
--
7f6c05aaa000-7f6c05b1d000 r-xp 00000000 08:02 1890493                    /usr/lib/libgcrypt.so.11.5.2
Rss:                  36 kB
--
7f6c05d20000-7f6c05d30000 r-xp 00000000 08:02 2081187                    /usr/lib/libtasn1.so.3.1.2
Rss:                  12 kB
--
7f6c05f30000-7f6c05f34000 r-xp 00000000 08:02 458960                     /lib/libcap.so.2.11
Rss:                  12 kB
--
7f6c06134000-7f6c06170000 r-xp 00000000 08:02 1889247                    /usr/lib/libdbus-1.so.3.4.0
Rss:                  36 kB
--
7f6c06372000-7f6c06376000 r-xp 00000000 08:02 1891735                    /usr/lib/libasyncns.so.0.1.0
Rss:                  12 kB
--
7f6c06576000-7f6c0657e000 r-xp 00000000 08:02 458834                     /lib/libwrap.so.0.7.6
Rss:                  20 kB
--
7f6c0677f000-7f6c06784000 r-xp 00000000 08:02 1888031                    /usr/lib/libXtst.so.6.1.0
Rss:                  12 kB
--
7f6c06985000-7f6c0698d000 r-xp 00000000 08:02 1885331                    /usr/lib/libSM.so.6.0.0
Rss:                  12 kB
--
7f6c06b8d000-7f6c06ba3000 r-xp 00000000 08:02 1897238                    /usr/lib/libICE.so.6.3.0
Rss:                  28 kB
--
7f6c06da8000-7f6c06dee000 r-xp 00000000 08:02 2147381                    /usr/lib/libpulsecommon-0.9.15.so
Rss:                  56 kB
--
7f6c06fef000-7f6c06ff1000 r-xp 00000000 08:02 460735                     /lib/libdl-2.9.so
Rss:                   8 kB
--
7f6c071f3000-7f6c0722d000 r-xp 00000000 08:02 2147380                    /usr/lib/libpulse.so.0.8.0
Rss:                  44 kB
--
7f6c0742f000-7f6c07578000 r-xp 00000000 08:02 460721                     /lib/libc-2.9.so
Rss:                 464 kB
--
7f6c07782000-7f6c07786000 r-xp 00000000 08:02 1892933                    /usr/lib/libvdeplug.so.2.1.0
Rss:                  12 kB
--
7f6c07986000-7f6c0798f000 r-xp 00000000 08:02 459991                     /lib/libbrlapi.so.0.5.1
Rss:                  20 kB
--
7f6c07b91000-7f6c07bcb000 r-xp 00000000 08:02 458804                     /lib/libncurses.so.5.6
Rss:                  76 kB
--
7f6c07dd0000-7f6c07f05000 r-xp 00000000 08:02 1886324                    /usr/lib/libX11.so.6.2.0
Rss:                 120 kB
--
7f6c0810b000-7f6c08173000 r-xp 00000000 08:02 1892212                    /usr/lib/libSDL-1.2.so.0.11.1
Rss:                  36 kB
--
7f6c083c1000-7f6c083c3000 r-xp 00000000 08:02 460719                     /lib/libutil-2.9.so
Rss:                   8 kB
--
7f6c085c4000-7f6c085cb000 r-xp 00000000 08:02 460727                     /lib/librt-2.9.so
Rss:                  24 kB
--
7f6c087cc000-7f6c087e2000 r-xp 00000000 08:02 460725                     /lib/libpthread-2.9.so
Rss:                  68 kB
--
7f6c089e7000-7f6c089f2000 r-xp 00000000 08:02 1889339                    /usr/lib/libpci.so.3.1.2
Rss:                  16 kB
--
7f6c08bf2000-7f6c08c0c000 r-xp 00000000 08:02 2146929                    /usr/lib/libbluetooth.so.3.2.5
Rss:                  32 kB
--
7f6c08e0d000-7f6c08eb4000 r-xp 00000000 08:02 1896347                    /usr/lib/libgnutls.so.26.11.5
Rss:                 136 kB
--
7f6c090bf000-7f6c090c2000 r-xp 00000000 08:02 2147382                    /usr/lib/libpulse-simple.so.0.0.2
Rss:                  12 kB
--
7f6c092c3000-7f6c093a0000 r-xp 00000000 08:02 1885450                    /usr/lib/libasound.so.2.0.0
Rss:                 176 kB
--
7f6c095a7000-7f6c095bd000 r-xp 00000000 08:02 1885377                    /usr/lib/libz.so.1.2.3.3
Rss:                  16 kB
--
7f6c097be000-7f6c09840000 r-xp 00000000 08:02 460724                     /lib/libm-2.9.so
Rss:                  20 kB
--
7f6c09a41000-7f6c09a5e000 r-xp 00000000 08:02 459078                     /lib/ld-2.9.so
Rss:                  96 kB
--
7f6c09b2c000-7f6c09b31000 r-xp 00000000 08:02 1886943                    /usr/lib/libgdbm.so.3.0.0
Rss:                  12 kB
--
7fff54d4f000-7fff54d50000 r-xp 00000000 00:00 0                          [vdso]
Rss:                   4 kB
--
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
Rss:                   0 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
