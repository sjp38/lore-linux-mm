Content-Type: text/plain;
  charset="iso-8859-1"
From: Rudmer van Dijk <rudmer@legolas.dynup.net>
Reply-To: rudmer@legolas.dynup.net
Message-Id: <200304141707.45601@gandalf>
Subject: Re: 2.5.67-mm3
Date: Mon, 14 Apr 2003 17:13:05 +0200
References: <20030414015313.4f6333ad.akpm@digeo.com> <20030414110326.GA19003@gnuppy.monkey.org>
In-Reply-To: <20030414110326.GA19003@gnuppy.monkey.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Bill Huey (Hui)" <billh@gnuppy.monkey.org>, Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 14 April 2003 13:03, Bill Huey (Hui) wrote:
> On Mon, Apr 14, 2003 at 01:53:13AM -0700, Andrew Morton wrote:
> > A bunch of new fixes, and a framebuffer update.  This should work a bit
> > better than -mm2.
> 
> make -f scripts/Makefile.build obj=arch/i386/boot arch/i386/boot/bzImage
>   ld -m elf_i386  -Ttext 0x0 -s --oformat binary -e begtext
>   arch/i386/boot/setup.o -o arch/i386/boot/setup 
>   arch/i386/boot/setup.o(.text+0x9a4): In function `video':
>   /tmp/ccyhvWWu.s:2925: undefined reference to `store_edid'
>   make[1]: *** [arch/i386/boot/setup] Error 1
>   make: *** [bzImage] Error 2
> 
> ---------------------------------------

got this also.
store_edid is only used when CONFIG_VIDEO_SELECT is set but the call to it is 
outside the #ifdef...

this patch fixes it. Maybe it is better to move the call to store_edid up 
inside the already avilable #ifdef but I'm not sure if that is possible

	Rudmer

--- linux-2.5.67-mm3/arch/i386/boot/video.S.orig	2003-04-14 
17:07:24.000000000 +0200
+++ linux-2.5.67-mm3/arch/i386/boot/video.S	2003-04-14 17:03:08.000000000 
+0200
@@ -135,7 +135,9 @@
 #endif /* CONFIG_VIDEO_RETAIN */
 #endif /* CONFIG_VIDEO_SELECT */
 	call	mode_params			# Store mode parameters
+#ifdef CONFIG_VIDEO_SELECT
 	call	store_edid
+#endif /* CONFIG_VIDEO_SELECT */
 	popw	%ds				# Restore original DS
 	ret
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
