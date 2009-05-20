Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A08086B0055
	for <linux-mm@kvack.org>; Tue, 19 May 2009 22:31:17 -0400 (EDT)
Date: Wed, 20 May 2009 10:31:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
	class  citizen
Message-ID: <20090520023101.GA8186@localhost>
References: <2f11576a0905190528n5eb29e3fme42785a76eed3551@mail.gmail.com> <20090520014445.GA7645@localhost> <20090520105159.743B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Content-Disposition: inline
In-Reply-To: <20090520105159.743B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 20, 2009 at 09:59:05AM +0800, KOSAKI Motohiro wrote:
> > On Tue, May 19, 2009 at 08:28:28PM +0800, KOSAKI Motohiro wrote:
> > > Hi
> > > 
> > > 2009/5/19 Wu Fengguang <fengguang.wu@intel.com>:
> > > > On Tue, May 19, 2009 at 04:06:35PM +0800, KOSAKI Motohiro wrote:
> > > >> > > > Like the console mode, the absolute nr_mapped drops considerably - to 1/13 of
> > > >> > > > the original size - during the streaming IO.
> > > >> > > >
> > > >> > > > The delta of pgmajfault is 3 vs 107 during IO, or 236 vs 393 during the whole
> > > >> > > > process.
> > > >> > >
> > > >> > > hmmm.
> > > >> > >
> > > >> > > about 100 page fault don't match Elladan's problem, I think.
> > > >> > > perhaps We missed any addional reproduce condition?
> > > >> >
> > > >> > Elladan's case is not the point of this test.
> > > >> > Elladan's IO is use-once, so probably not a caching problem at all.
> > > >> >
> > > >> > This test case is specifically devised to confirm whether this patch
> > > >> > works as expected. Conclusion: it is.
> > > >>
> > > >> Dejection ;-)
> > > >>
> > > >> The number should address the patch is useful or not. confirming as expected
> > > >> is not so great.
> > > >
> > > > OK, let's make the conclusion in this way:
> > > >
> > > > The changelog analyzed the possible beneficial situation, and this
> > > > test backs that theory with real numbers, ie: it successfully stops
> > > > major faults when the active file list is slowly scanned when there
> > > > are partially cache hot streaming IO.
> > > >
> > > > Another (amazing) finding of the test is, only around 1/10 mapped pages
> > > > are actively referenced in the absence of user activities.
> > > >
> > > > Shall we protect the remaining 9/10 inactive ones? This is a question ;-)
> > > 
> > > Unfortunately, I don't reproduce again.
> > > I don't apply your patch yet. but mapped ratio is reduced only very little.
> > 
> > mapped ratio or absolute numbers? The ratio wont change much because
> > nr_mapped is already small.
> 
> My box is running Fedora 10 initlevel 5 (GNOME desktop).
> 
> many GNOME component is mapped very many process (likes >50).
> Thus, these page aren't dropped by typical any workload.

Yeah, that's possible (but sounds bloated in regard of active
working set size).

> > > I think smem can show which library evicted.  Can you try it?
> > > 
> > > download:  http://www.selenic.com/smem/
> > > usage:   ./smem -m -r --abbreviate
> > 
> > Sure, but I don't see much change in its output (see attachments).
> > 
> > smem-console-0 is collected after fresh boot,
> > smem-console-1 is collected after the big IO.
> 
> hmmmm, your result has following characatistics.
> 
> - no graphics component
> - very few mapped library
>   (it is almost only zsh library)
> 
> Can you try test on X environment?

Sure, see the attached smem-x-0/1. This time we see sufficient differences.

> > > We can't decide 9/10 is important or not. we need know actual evicted file list.
> > 
> > Right. But what I measured is the activeness. Almost zero major page
> > faults means the evicted 90% mapped pages are inactive during the
> > long 300 seconds of IO.
> 
> Agreed.
> IOW, I don't think your test environment is typical desktop...

Kind of :)  It's fluxbox + terminal + firefox, a bare desktop for
testing things out.


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=smem-x-1

Map                                       PIDs   AVGPSS      PSS 
[heap]                                      15     2.7M    40.5M 
<anonymous>                                 15   390.0K     5.7M 
/usr/lib/xulrunner-1.9/libxul.so             1     2.1M     2.1M 
/usr/bin/python2.5                           1     1.0M     1.0M 
/lib/libc-2.9.so                            15    43.0K   649.0K 
[stack]                                     15    38.0K   584.0K 
/bin/zsh4                                    3   176.0K   528.0K 
/usr/lib/libX11.so.6.2.0                     7    40.0K   284.0K 
/usr/lib/libmozjs.so.1d                      1   232.0K   232.0K 
/usr/lib/libscim-1.0.so.8.2.3                3    76.0K   228.0K 
/lib/ld-2.9.so                              15    14.0K   220.0K 
/usr/lib/libstdc++.so.6.0.10                 5    42.0K   211.0K 
/usr/lib/zsh/4.3.9/zsh/zle.so                3    58.0K   176.0K 
/usr/lib/libORBit-2.so.0.1.0                 2    88.0K   176.0K 
/usr/lib/libsqlite3.so.0.8.6                 1   160.0K   160.0K 
/lib/libdl-2.9.so                           15     8.0K   128.0K 
/usr/bin/fluxbox                             1   120.0K   120.0K 
/lib/libm-2.9.so                            10    10.0K   109.0K 
/lib/libpthread-2.9.so                       8    13.0K   105.0K 
/SYSV00000000                                2    52.0K   104.0K 
/usr/lib/libfreetype.so.6.3.18               4    24.0K    96.0K 
/lib/libnss_compat-2.9.so                   11     8.0K    94.0K 
/lib/libncursesw.so.5.7                      3    30.0K    92.0K 
/usr/lib/libgtk-x11-2.0.so.0.1600.1          2    44.0K    88.0K 
/lib/libnss_nis-2.9.so                      11     8.0K    88.0K 
/lib/libnss_files-2.9.so                    11     8.0K    88.0K 
/lib/libnsl-2.9.so                          11     8.0K    88.0K 
/usr/lib/nss/libnssckbi.so                   1    80.0K    80.0K 
/usr/lib/libxml2.so.2.6.32                   2    40.0K    80.0K 
/usr/lib/libnspr4.so.0d                      1    76.0K    76.0K 
/usr/lib/libglib-2.0.so.0.2000.1             4    17.0K    68.0K 
/usr/lib/libbonobo-2.so.0.0.0                1    68.0K    68.0K 
/usr/lib/locale/locale-archive              10     5.0K    52.0K 
/usr/lib/libgdk-x11-2.0.so.0.1600.1          2    26.0K    52.0K 
/usr/lib/libgconf-2.so.4.1.5                 2    25.0K    50.0K 
/usr/lib/libdirectfb-1.2.so.0.7.0            3    16.0K    48.0K 
/usr/lib/libgnutls.so.26.11.5                1    44.0K    44.0K 
/usr/lib/libgobject-2.0.so.0.2000.1          4    10.0K    41.0K 
/usr/lib/zsh/4.3.9/zsh/complete.so           3    13.0K    40.0K 
/usr/lib/libexpat.so.1.5.2                   5     8.0K    40.0K 
/usr/lib/libperl.so.5.10.0                   1    36.0K    36.0K 
/usr/lib/libpango-1.0.so.0.2400.0            3    12.0K    36.0K 
/usr/lib/libnss3.so.1d                       1    36.0K    36.0K 
/usr/lib/libcairo.so.2.10800.6               3    12.0K    36.0K 
/usr/bin/urxvt                               1    36.0K    36.0K 
/usr/lib/libxcb.so.1.1.0                     7     5.0K    35.0K 
/usr/lib/python2.5/lib-dynload/operator.     1    32.0K    32.0K 
/usr/lib/libfontconfig.so.1.3.0              4     8.0K    32.0K 
/lib/libselinux.so.1                         4     8.0K    32.0K 
/usr/lib/libpixman-1.so.0.12.0               3    10.0K    30.0K 
/usr/lib/libXdmcp.so.6.0.0                   7     4.0K    28.0K 
/usr/lib/libXau.so.6.0.0                     7     4.0K    28.0K 
/lib/librt-2.9.so                            3     8.0K    25.0K 
/usr/lib/python2.5/lib-dynload/_struct.s     1    24.0K    24.0K 
/usr/lib/libtiff.so.4.2.1                    2    12.0K    24.0K 
/usr/lib/libgnomeui-2.so.0.2000.1            1    24.0K    24.0K 
/usr/lib/libgio-2.0.so.0.2000.1              3     8.0K    24.0K 
/usr/lib/libatk-1.0.so.0.2209.1              2    12.0K    24.0K 
/usr/lib/libXt.so.6.0.0                      1    24.0K    24.0K 
/usr/lib/gnome-vfs-2.0/modules/libfile.s     1    24.0K    24.0K 
/lib/libutil-2.9.so                          2    12.0K    24.0K 
/lib/libgcc_s.so.1                           6     4.0K    24.0K 
/bin/bash                                    1    24.0K    24.0K 
/usr/lib/python2.5/lib-dynload/time.so       1    20.0K    20.0K 
/usr/lib/python2.5/lib-dynload/strop.so      1    20.0K    20.0K 
/usr/lib/python2.5/lib-dynload/_locale.s     1    20.0K    20.0K 
/usr/lib/libnssutil3.so.1d                   1    20.0K    20.0K 
/usr/lib/libgnomevfs-2.so.0.2200.0           1    20.0K    20.0K 
/usr/lib/libbonoboui-2.so.0.0.0              1    20.0K    20.0K 
/lib/libncurses.so.5.7                       1    20.0K    20.0K 
/usr/lib/zsh/4.3.9/zsh/zutil.so              3     5.0K    16.0K 
/usr/lib/zsh/4.3.9/zsh/rlimits.so            3     5.0K    16.0K 
/usr/lib/scim-1.0/scim-panel-gtk             1    16.0K    16.0K 
/usr/lib/libz.so.1.2.3.3                     4     4.0K    16.0K 
/usr/lib/libsmime3.so.1d                     1    16.0K    16.0K 
/usr/lib/libpng12.so.0.27.0                  4     4.0K    16.0K 
/usr/lib/libpcre.so.3.12.1                   4     4.0K    16.0K 
/usr/lib/libgsf-1.so.114.0.12                1    16.0K    16.0K 
/usr/lib/libgmodule-2.0.so.0.2000.1          4     4.0K    16.0K 
/usr/lib/libgcrypt.so.11.5.2                 1    16.0K    16.0K 
/usr/lib/libcroco-0.6.so.3.0.1               1    16.0K    16.0K 
/usr/lib/libbonobo-activation.so.4.0.0       1    16.0K    16.0K 
/usr/lib/libaudiofile.so.0.0.2               1    16.0K    16.0K 
/usr/lib/libXrender.so.1.3.0                 4     4.0K    16.0K 
/usr/lib/libXfixes.so.3.1.0                  4     4.0K    16.0K 
/usr/lib/libXext.so.6.4.0                    4     4.0K    16.0K 
/usr/lib/libXcursor.so.1.0.2                 4     4.0K    16.0K 
/usr/lib/libAfterImage.so.0.99               1    16.0K    16.0K 
/usr/lib/iceweasel/components/libbrowser     1    16.0K    16.0K 
/lib/libcap.so.2.11                          3     5.0K    16.0K 
/lib/libbz2.so.1.0.4                         2     8.0K    16.0K 
/lib/libattr.so.1.1.0                        4     4.0K    16.0K 
/usr/lib/libgthread-2.0.so.0.2000.1          3     5.0K    15.0K 
/usr/lib/libgconf2-4/gconfd-2                1    14.0K    14.0K 
/usr/lib/libdbus-1.so.3.4.0                  1    13.0K    13.0K 
/usr/lib/zsh/4.3.9/zsh/terminfo.so           3     4.0K    12.0K 
/usr/lib/zsh/4.3.9/zsh/parameter.so          3     4.0K    12.0K 
/usr/lib/zsh/4.3.9/zsh/computil.so           1    12.0K    12.0K 
/usr/lib/zsh/4.3.9/zsh/complist.so           3     4.0K    12.0K 
/usr/lib/scim-1.0/1.4.0/IMEngine/pinyin.     1    12.0K    12.0K 
/usr/lib/scim-1.0/1.4.0/FrontEnd/x11.so      1    12.0K    12.0K 
/usr/lib/python2.5/lib-dynload/grp.so        1    12.0K    12.0K 
/usr/lib/perl/5.10.0/auto/POSIX/POSIX.so     1    12.0K    12.0K 
/usr/lib/libxcb-render.so.0.0.0              3     4.0K    12.0K 
/usr/lib/libxcb-render-util.so.0.0.0         3     4.0K    12.0K 
/usr/lib/libssl3.so.1d                       1    12.0K    12.0K 
/usr/lib/libpangoft2-1.0.so.0.2400.0         3     4.0K    12.0K 
/usr/lib/libpangocairo-1.0.so.0.2400.0       3     4.0K    12.0K 
/usr/lib/libjpeg.so.62.0.0                   3     4.0K    12.0K 
/usr/lib/libid3tag.so.0.3.0                  1    12.0K    12.0K 
/usr/lib/libhunspell-1.2.so.0.0.0            1    12.0K    12.0K 
/usr/lib/libgdk_pixbuf-2.0.so.0.1600.1       3     4.0K    12.0K 
/usr/lib/libfusion-1.2.so.0.7.0              3     4.0K    12.0K 
/usr/lib/libdirect-1.2.so.0.7.0              3     4.0K    12.0K 
/usr/lib/libXrandr.so.2.2.0                  3     4.0K    12.0K 
/usr/lib/libXinerama.so.1.0.0                3     4.0K    12.0K 
/usr/lib/libSM.so.6.0.0                      3     4.0K    12.0K 
/usr/lib/libICE.so.6.3.0                     3     4.0K    12.0K 
/usr/lib/libdbus-glib-1.so.2.1.0             1    10.0K    10.0K 
/usr/lib/xulrunner-1.9/components/libimg     1     8.0K     8.0K 
/usr/lib/scim-1.0/1.4.0/Config/simple.so     2     4.0K     8.0K 
/usr/lib/pango/1.6.0/modules/pango-basic     2     4.0K     8.0K 
/usr/lib/nss/libsoftokn3.so                  1     8.0K     8.0K 
/usr/lib/nss/libfreebl3.so                   1     8.0K     8.0K 
/usr/lib/libscim-x11utils-1.0.so.8.2.3       2     4.0K     8.0K 
/usr/lib/librsvg-2.so.2.22.3                 1     8.0K     8.0K 
/usr/lib/liblcms.so.1.0.16                   1     8.0K     8.0K 
/usr/lib/libgnomecanvas-2.so.0.2001.0        1     8.0K     8.0K 
/usr/lib/libgnome-2.so.0.1999.2              1     8.0K     8.0K 
/usr/lib/libgif.so.4.1.6                     2     4.0K     8.0K 
/usr/lib/libXi.so.6.0.0                      2     4.0K     8.0K 
/usr/lib/libXft.so.2.1.2                     2     4.0K     8.0K 
/usr/lib/libXdamage.so.1.1.0                 2     4.0K     8.0K 
/usr/lib/libXcomposite.so.1.0.0              2     4.0K     8.0K 
/usr/lib/libORBitCosNaming-2.so.0.1.0        1     8.0K     8.0K 
/usr/lib/gtk-2.0/2.10.0/loaders/libpixbu     2     4.0K     8.0K 
/usr/lib/gconv/UTF-16.so                     1     8.0K     8.0K 
/usr/lib/gconv/ISO8859-1.so                  1     8.0K     8.0K 
/usr/bin/dbus-daemon                         1     8.0K     8.0K 
/lib/libresolv-2.9.so                        1     8.0K     8.0K 
/lib/libnss_dns-2.9.so                       1     8.0K     8.0K 
/lib/libcrypt-2.9.so                         1     8.0K     8.0K 
/usr/lib/libgconf2-4/2/libgconfbackend-x     1     6.0K     6.0K 
/usr/lib/xulrunner-1.9/xulrunner-stub        1     4.0K     4.0K 
/usr/lib/xulrunner-1.9/libxpcom.so           1     4.0K     4.0K 
/usr/lib/xulrunner-1.9/components/libnkg     1     4.0K     4.0K 
/usr/lib/xulrunner-1.9/components/libmoz     1     4.0K     4.0K 
/usr/lib/xulrunner-1.9/components/libdbu     1     4.0K     4.0K 
/usr/lib/scim-1.0/scim-launcher              1     4.0K     4.0K 
/usr/lib/scim-1.0/scim-helper-manager        1     4.0K     4.0K 
/usr/lib/perl/5.10.0/auto/List/Util/Util     1     4.0K     4.0K 
/usr/lib/perl/5.10.0/auto/Fcntl/Fcntl.so     1     4.0K     4.0K 
/usr/lib/nss/libnssdbm3.so                   1     4.0K     4.0K 
/usr/lib/libtasn1.so.3.0.16                  1     4.0K     4.0K 
/usr/lib/libstartup-notification-1.so.0.     1     4.0K     4.0K 
/usr/lib/libscim-gtkutils-1.0.so.8.2.3       1     4.0K     4.0K 
/usr/lib/libplds4.so.0d                      1     4.0K     4.0K 
/usr/lib/libplc4.so.0d                       1     4.0K     4.0K 
/usr/lib/libgpg-error.so.0.3.0               1     4.0K     4.0K 
/usr/lib/libgnome-keyring.so.0.1.1           1     4.0K     4.0K 
/usr/lib/libgailutil.so.18.0.1               1     4.0K     4.0K 
/usr/lib/libfam.so.0.0.0                     1     4.0K     4.0K 
/usr/lib/libesd.so.0.2.36                    1     4.0K     4.0K 
/usr/lib/libavahi-glib.so.1.0.1              1     4.0K     4.0K 
/usr/lib/libavahi-common.so.3.5.0            1     4.0K     4.0K 
/usr/lib/libavahi-client.so.3.2.4            1     4.0K     4.0K 
/usr/lib/libart_lgpl_2.so.2.3.20             1     4.0K     4.0K 
/usr/lib/libXpm.so.4.11.0                    1     4.0K     4.0K 
/usr/lib/libImlib2.so.1.4.0                  1     4.0K     4.0K 
/usr/lib/libAfterBase.so.0.99                1     4.0K     4.0K 
/usr/lib/imlib2/loaders/zlib.so              1     4.0K     4.0K 
/usr/lib/imlib2/loaders/xpm.so               1     4.0K     4.0K 
/usr/lib/imlib2/loaders/tiff.so              1     4.0K     4.0K 
/usr/lib/imlib2/loaders/tga.so               1     4.0K     4.0K 
/usr/lib/imlib2/loaders/pnm.so               1     4.0K     4.0K 
/usr/lib/imlib2/loaders/png.so               1     4.0K     4.0K 
/usr/lib/imlib2/loaders/lbm.so               1     4.0K     4.0K 
/usr/lib/imlib2/loaders/jpeg.so              1     4.0K     4.0K 
/usr/lib/imlib2/loaders/id3.so               1     4.0K     4.0K 
/usr/lib/imlib2/loaders/gif.so               1     4.0K     4.0K 
/usr/lib/imlib2/loaders/bz2.so               1     4.0K     4.0K 
/usr/lib/imlib2/loaders/bmp.so               1     4.0K     4.0K 
/usr/lib/imlib2/loaders/argb.so              1     4.0K     4.0K 
/usr/lib/iceweasel/components/libbrowser     1     4.0K     4.0K 
/usr/lib/gtk-2.0/2.10.0/immodules/im-xim     1     4.0K     4.0K 
/usr/bin/xinit                               1     4.0K     4.0K 
/usr/bin/dbus-launch                         1     4.0K     4.0K 
/lib/libpopt.so.0.0.0                        1     4.0K     4.0K 
/lib/libnss_mdns4_minimal.so.2               1     4.0K     4.0K 
/lib/libnss_mdns4.so.2                       1     4.0K     4.0K 
/lib/libacl.so.1.1.0                         1     4.0K     4.0K 
[vsyscall]                                  15        0        0 
[vdso]                                      15        0        0 
/var/cache/fontconfig/e13b20fdb08344e0e6     4        0        0 
/var/cache/fontconfig/de156ccd2eddbdc19d     4        0        0 
/var/cache/fontconfig/99e8ed0e538f840c56     4        0        0 
/var/cache/fontconfig/945677eb7aeaf62f1d     4        0        0 
/var/cache/fontconfig/6d41288fd70b0be22e     4        0        0 
/var/cache/fontconfig/0fafd173547752dce4     4        0        0 
/var/cache/fontconfig/089dead882dea3570f     4        0        0 
/usr/share/mime/mime.cache                   1        0        0 
/usr/share/fonts/truetype/ttf-dejavu/Dej     1        0        0 
/usr/share/fonts/truetype/ttf-bitstream-     1        0        0 
/usr/share/fonts/truetype/ttf-bitstream-     2        0        0 
/usr/share/fonts/truetype/ttf-bitstream-     1        0        0 
/usr/share/fonts/X11/Type1/c0583bt_.pfb      1        0        0 
/usr/share/fonts/X11/Type1/c0419bt_.pfb      2        0        0 
/usr/share/fluxbox/nls/en_US.UTF-8/fluxb     1        0        0 
/usr/lib/gconv/gconv-modules.cache           6        0        0 
/home/wfg/.fontconfig/cabbd14511b9e8a55e     4        0        0 

--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=smem-x-0

Map                                       PIDs   AVGPSS      PSS 
[heap]                                      15     2.3M    35.2M 
/usr/lib/xulrunner-1.9/libxul.so             1    11.0M    11.0M 
<anonymous>                                 15   390.0K     5.7M 
/usr/lib/libgtk-x11-2.0.so.0.1600.1          2   934.0K     1.8M 
/usr/lib/libperl.so.5.10.0                   1     1.2M     1.2M 
/usr/bin/python2.5                           1     1.0M     1.0M 
/usr/bin/fluxbox                             1  1000.0K  1000.0K 
/usr/lib/libX11.so.6.2.0                     7   114.0K   798.0K 
/usr/lib/libstdc++.so.6.0.10                 5   143.0K   717.0K 
/usr/lib/libscim-1.0.so.8.2.3                3   227.0K   682.0K 
/bin/zsh4                                    3   215.0K   647.0K 
/lib/libc-2.9.so                            15    40.0K   613.0K 
[stack]                                     15    39.0K   588.0K 
/usr/lib/libmozjs.so.1d                      1   556.0K   556.0K 
/usr/lib/libnss3.so.1d                       1   528.0K   528.0K 
/usr/lib/libgdk-x11-2.0.so.0.1600.1          2   250.0K   500.0K 
/bin/bash                                    1   460.0K   460.0K 
/usr/lib/libfreetype.so.6.3.18               4   108.0K   433.0K 
/usr/lib/libsqlite3.so.0.8.6                 1   412.0K   412.0K 
/usr/lib/nss/libnssckbi.so                   1   384.0K   384.0K 
/usr/bin/urxvt                               1   364.0K   364.0K 
/usr/lib/libcairo.so.2.10800.6               3   109.0K   329.0K 
/usr/lib/libbonobo-2.so.0.0.0                1   312.0K   312.0K 
/usr/lib/zsh/4.3.9/zsh/zle.so                3   103.0K   311.0K 
/usr/lib/libORBit-2.so.0.1.0                 2   155.0K   310.0K 
/usr/lib/libgnomeui-2.so.0.2000.1            1   308.0K   308.0K 
/usr/lib/libglib-2.0.so.0.2000.1             4    70.0K   283.0K 
/usr/lib/libpango-1.0.so.0.2400.0            3    92.0K   277.0K 
/usr/lib/libxml2.so.2.6.32                   2   126.0K   252.0K 
/usr/lib/libgnomevfs-2.so.0.2200.0           1   244.0K   244.0K 
/lib/libm-2.9.so                            10    24.0K   240.0K 
/lib/libncursesw.so.5.7                      3    65.0K   195.0K 
/usr/lib/libnspr4.so.0d                      1   192.0K   192.0K 
/usr/lib/libgnutls.so.26.11.5                1   180.0K   180.0K 
/usr/lib/scim-1.0/1.4.0/FrontEnd/x11.so      1   172.0K   172.0K 
/usr/lib/libfontconfig.so.1.3.0              4    41.0K   166.0K 
/usr/lib/libgio-2.0.so.0.2000.1              3    52.0K   158.0K 
/usr/lib/libbonoboui-2.so.0.0.0              1   156.0K   156.0K 
/lib/ld-2.9.so                              15    10.0K   156.0K 
/usr/lib/zsh/4.3.9/zsh/complete.so           3    51.0K   153.0K 
/usr/lib/libgobject-2.0.so.0.2000.1          4    37.0K   148.0K 
/usr/lib/libpng12.so.0.27.0                  4    36.0K   146.0K 
/usr/lib/libgconf-2.so.4.1.5                 2    73.0K   146.0K 
/usr/lib/nss/libsoftokn3.so                  1   128.0K   128.0K 
/usr/lib/scim-1.0/1.4.0/IMEngine/pinyin.     1   124.0K   124.0K 
/usr/lib/libexpat.so.1.5.2                   5    24.0K   124.0K 
/lib/libdl-2.9.so                           15     8.0K   120.0K 
/usr/lib/libdirectfb-1.2.so.0.7.0            3    39.0K   119.0K 
/usr/lib/libpangoft2-1.0.so.0.2400.0         3    38.0K   114.0K 
/usr/lib/scim-1.0/scim-panel-gtk             1   112.0K   112.0K 
/usr/lib/iceweasel/components/libbrowser     1   108.0K   108.0K 
/usr/lib/libXt.so.6.0.0                      1   104.0K   104.0K 
/SYSV00000000                                2    52.0K   104.0K 
/lib/libnss_files-2.9.so                    11     9.0K    99.0K 
/usr/lib/locale/locale-archive              10     9.0K    97.0K 
/usr/lib/libImlib2.so.1.4.0                  1    96.0K    96.0K 
/usr/lib/libAfterImage.so.0.99               1    96.0K    96.0K 
/lib/libncurses.so.5.7                       1    96.0K    96.0K 
/lib/libpthread-2.9.so                       8    11.0K    95.0K 
/lib/libnss_nis-2.9.so                      11     8.0K    94.0K 
/lib/libnss_compat-2.9.so                   11     8.0K    94.0K 
/lib/libnsl-2.9.so                          11     8.0K    94.0K 
/usr/lib/libbonobo-activation.so.4.0.0       1    92.0K    92.0K 
/usr/lib/libxcb.so.1.1.0                     7    12.0K    89.0K 
/usr/lib/libgdk_pixbuf-2.0.so.0.1600.1       3    29.0K    89.0K 
/usr/lib/nss/libnssdbm3.so                   1    88.0K    88.0K 
/usr/lib/libnssutil3.so.1d                   1    84.0K    84.0K 
/usr/lib/libgsf-1.so.114.0.12                1    84.0K    84.0K 
/usr/lib/libatk-1.0.so.0.2209.1              2    42.0K    84.0K 
/usr/share/fonts/truetype/ttf-dejavu/Dej     1    80.0K    80.0K 
/usr/lib/libssl3.so.1d                       1    80.0K    80.0K 
/usr/lib/libpixman-1.so.0.12.0               3    26.0K    79.0K 
/usr/lib/libgnome-2.so.0.1999.2              1    76.0K    76.0K 
/usr/lib/libz.so.1.2.3.3                     4    18.0K    75.0K 
/usr/lib/libXft.so.2.1.2                     2    36.0K    72.0K 
/usr/bin/dbus-daemon                         1    70.0K    70.0K 
/usr/lib/libsmime3.so.1d                     1    68.0K    68.0K 
/usr/lib/perl/5.10.0/auto/POSIX/POSIX.so     1    64.0K    64.0K 
/usr/lib/libcroco-0.6.so.3.0.1               1    64.0K    64.0K 
/usr/lib/libtiff.so.4.2.1                    2    30.0K    60.0K 
/usr/lib/libgnomecanvas-2.so.0.2001.0        1    60.0K    60.0K 
/usr/lib/nss/libfreebl3.so                   1    56.0K    56.0K 
/usr/lib/libhunspell-1.2.so.0.0.0            1    56.0K    56.0K 
/usr/lib/libgcrypt.so.11.5.2                 1    52.0K    52.0K 
/usr/lib/libXpm.so.4.11.0                    1    52.0K    52.0K 
/usr/lib/gnome-vfs-2.0/modules/libfile.s     1    52.0K    52.0K 
/usr/lib/libXext.so.6.4.0                    4    12.0K    50.0K 
/usr/lib/libpangocairo-1.0.so.0.2400.0       3    16.0K    49.0K 
/usr/lib/xulrunner-1.9/components/libimg     1    48.0K    48.0K 
/usr/lib/librsvg-2.so.2.22.3                 1    48.0K    48.0K 
/usr/lib/libaudiofile.so.0.0.2               1    48.0K    48.0K 
/usr/lib/libAfterBase.so.0.99                1    48.0K    48.0K 
/lib/libselinux.so.1                         4    12.0K    48.0K 
/usr/lib/libXrender.so.1.3.0                 4    11.0K    45.0K 
/usr/share/fonts/truetype/ttf-bitstream-     1    44.0K    44.0K 
/usr/share/fonts/truetype/ttf-bitstream-     1    44.0K    44.0K 
/usr/lib/zsh/4.3.9/zsh/computil.so           1    44.0K    44.0K 
/usr/lib/liblcms.so.1.0.16                   1    44.0K    44.0K 
/usr/lib/libid3tag.so.0.3.0                  1    44.0K    44.0K 
/lib/libresolv-2.9.so                        1    44.0K    44.0K 
/usr/lib/libICE.so.6.3.0                     3    14.0K    43.0K 
/home/wfg/.fontconfig/cabbd14511b9e8a55e     4    10.0K    42.0K 
/usr/share/fonts/X11/Type1/c0583bt_.pfb      1    40.0K    40.0K 
/usr/share/fonts/X11/Type1/c0419bt_.pfb      2    20.0K    40.0K 
/usr/lib/libscim-gtkutils-1.0.so.8.2.3       1    40.0K    40.0K 
/var/cache/fontconfig/e13b20fdb08344e0e6     4     9.0K    39.0K 
/usr/lib/libdirect-1.2.so.0.7.0              3    13.0K    39.0K 
/usr/lib/libXcursor.so.1.0.2                 4     9.0K    38.0K 
/usr/lib/scim-1.0/scim-helper-manager        1    36.0K    36.0K 
/usr/lib/libXdmcp.so.6.0.0                   7     5.0K    36.0K 
/usr/lib/iceweasel/components/libbrowser     1    36.0K    36.0K 
/lib/libgcc_s.so.1                           6     6.0K    36.0K 
/usr/lib/zsh/4.3.9/zsh/zutil.so              3    11.0K    35.0K 
/usr/lib/zsh/4.3.9/zsh/parameter.so          3    11.0K    34.0K 
/var/cache/fontconfig/945677eb7aeaf62f1d     4     8.0K    33.0K 
/var/cache/fontconfig/6d41288fd70b0be22e     4     8.0K    33.0K 
/usr/lib/zsh/4.3.9/zsh/complist.so           3    11.0K    33.0K 
/usr/lib/libXau.so.6.0.0                     7     4.0K    33.0K 
/usr/share/fonts/truetype/ttf-bitstream-     2    16.0K    32.0K 
/usr/lib/xulrunner-1.9/components/libmoz     1    32.0K    32.0K 
/usr/lib/python2.5/lib-dynload/operator.     1    32.0K    32.0K 
/usr/lib/libgconf2-4/2/libgconfbackend-x     1    32.0K    32.0K 
/usr/lib/libdbus-1.so.3.4.0                  1    32.0K    32.0K 
/usr/lib/libXi.so.6.0.0                      2    16.0K    32.0K 
/usr/lib/libxcb-render.so.0.0.0              3    10.0K    31.0K 
/usr/lib/libfusion-1.2.so.0.7.0              3    10.0K    31.0K 
/usr/lib/libjpeg.so.62.0.0                   3    10.0K    30.0K 
/usr/lib/libXfixes.so.3.1.0                  4     7.0K    30.0K 
/lib/librt-2.9.so                            3     9.0K    29.0K 
/usr/share/mime/mime.cache                   1    28.0K    28.0K 
/usr/lib/xulrunner-1.9/xulrunner-stub        1    28.0K    28.0K 
/usr/lib/xulrunner-1.9/components/libnkg     1    28.0K    28.0K 
/usr/lib/scim-1.0/1.4.0/Config/simple.so     2    14.0K    28.0K 
/usr/lib/libgnome-keyring.so.0.1.1           1    28.0K    28.0K 
/usr/lib/libgconf2-4/gconfd-2                1    28.0K    28.0K 
/usr/lib/gtk-2.0/2.10.0/immodules/im-xim     1    28.0K    28.0K 
/lib/libpopt.so.0.0.0                        1    28.0K    28.0K 
/lib/libbz2.so.1.0.4                         2    14.0K    28.0K 
/lib/libattr.so.1.1.0                        4     7.0K    28.0K 
/usr/lib/libXrandr.so.2.2.0                  3     9.0K    27.0K 
/usr/lib/xulrunner-1.9/components/libdbu     1    24.0K    24.0K 
/usr/lib/python2.5/lib-dynload/_struct.s     1    24.0K    24.0K 
/usr/lib/perl/5.10.0/auto/List/Util/Util     1    24.0K    24.0K 
/usr/lib/libstartup-notification-1.so.0.     1    24.0K    24.0K 
/usr/lib/libart_lgpl_2.so.2.3.20             1    24.0K    24.0K 
/usr/lib/libORBitCosNaming-2.so.0.1.0        1    24.0K    24.0K 
/usr/lib/gtk-2.0/2.10.0/loaders/libpixbu     2    12.0K    24.0K 
/lib/libnss_dns-2.9.so                       1    24.0K    24.0K 
/usr/lib/libxcb-render-util.so.0.0.0         3     7.0K    23.0K 
/usr/lib/libgmodule-2.0.so.0.2000.1          4     5.0K    22.0K 
/usr/lib/zsh/4.3.9/zsh/rlimits.so            3     7.0K    21.0K 
/usr/lib/libdbus-glib-1.so.2.1.0             1    21.0K    21.0K 
/usr/lib/libSM.so.6.0.0                      3     7.0K    21.0K 
/lib/libcap.so.2.11                          3     7.0K    21.0K 
/usr/lib/python2.5/lib-dynload/time.so       1    20.0K    20.0K 
/usr/lib/python2.5/lib-dynload/strop.so      1    20.0K    20.0K 
/usr/lib/python2.5/lib-dynload/_locale.s     1    20.0K    20.0K 
/usr/lib/libgif.so.4.1.6                     2    10.0K    20.0K 
/usr/lib/libgailutil.so.18.0.1               1    20.0K    20.0K 
/usr/lib/libfam.so.0.0.0                     1    20.0K    20.0K 
/usr/lib/libesd.so.0.2.36                    1    20.0K    20.0K 
/usr/lib/gconv/UTF-16.so                     1    20.0K    20.0K 
/usr/bin/dbus-launch                         1    20.0K    20.0K 
/usr/lib/libpcre.so.3.12.1                   4     4.0K    19.0K 
/usr/lib/libXinerama.so.1.0.0                3     6.0K    19.0K 
/usr/lib/zsh/4.3.9/zsh/terminfo.so           3     6.0K    18.0K 
/usr/lib/libgthread-2.0.so.0.2000.1          3     6.0K    18.0K 
/lib/libutil-2.9.so                          2     9.0K    18.0K 
/usr/lib/gconv/gconv-modules.cache           6     2.0K    17.0K 
/usr/share/fluxbox/nls/en_US.UTF-8/fluxb     1    16.0K    16.0K 
/usr/lib/xulrunner-1.9/libxpcom.so           1    16.0K    16.0K 
/usr/lib/scim-1.0/scim-launcher              1    16.0K    16.0K 
/usr/lib/perl/5.10.0/auto/Fcntl/Fcntl.so     1    16.0K    16.0K 
/usr/lib/pango/1.6.0/modules/pango-basic     2     8.0K    16.0K 
/usr/lib/libtasn1.so.3.0.16                  1    16.0K    16.0K 
/usr/lib/libscim-x11utils-1.0.so.8.2.3       2     8.0K    16.0K 
/usr/lib/libplc4.so.0d                       1    16.0K    16.0K 
/usr/lib/libavahi-client.so.3.2.4            1    16.0K    16.0K 
/usr/lib/libXdamage.so.1.1.0                 2     8.0K    16.0K 
/usr/lib/libXcomposite.so.1.0.0              2     8.0K    16.0K 
/usr/lib/imlib2/loaders/png.so               1    16.0K    16.0K 
/usr/lib/imlib2/loaders/id3.so               1    16.0K    16.0K 
/usr/lib/gconv/ISO8859-1.so                  1    16.0K    16.0K 
/usr/bin/xinit                               1    16.0K    16.0K 
/lib/libacl.so.1.1.0                         1    16.0K    16.0K 
/usr/lib/libavahi-common.so.3.5.0            1    14.0K    14.0K 
/usr/lib/python2.5/lib-dynload/grp.so        1    12.0K    12.0K 
/usr/lib/libplds4.so.0d                      1    12.0K    12.0K 
/usr/lib/libavahi-glib.so.1.0.1              1    12.0K    12.0K 
/usr/lib/imlib2/loaders/xpm.so               1    12.0K    12.0K 
/usr/lib/imlib2/loaders/tiff.so              1    12.0K    12.0K 
/usr/lib/imlib2/loaders/tga.so               1    12.0K    12.0K 
/usr/lib/imlib2/loaders/pnm.so               1    12.0K    12.0K 
/usr/lib/imlib2/loaders/lbm.so               1    12.0K    12.0K 
/usr/lib/imlib2/loaders/jpeg.so              1    12.0K    12.0K 
/usr/lib/imlib2/loaders/gif.so               1    12.0K    12.0K 
/usr/lib/imlib2/loaders/bmp.so               1    12.0K    12.0K 
/lib/libnss_mdns4_minimal.so.2               1    12.0K    12.0K 
/var/cache/fontconfig/de156ccd2eddbdc19d     4     2.0K     9.0K 
/lib/libcrypt-2.9.so                         1     9.0K     9.0K 
/usr/lib/libgpg-error.so.0.3.0               1     8.0K     8.0K 
/usr/lib/imlib2/loaders/zlib.so              1     8.0K     8.0K 
/usr/lib/imlib2/loaders/bz2.so               1     8.0K     8.0K 
/usr/lib/imlib2/loaders/argb.so              1     8.0K     8.0K 
/var/cache/fontconfig/99e8ed0e538f840c56     4     1.0K     6.0K 
/var/cache/fontconfig/089dead882dea3570f     4     1.0K     6.0K 
/var/cache/fontconfig/0fafd173547752dce4     4        0     3.0K 
[vsyscall]                                  15        0        0 
[vdso]                                      15        0        0 

--zYM0uCDKw75PZbzx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
