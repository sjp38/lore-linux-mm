Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B709E6B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 11:10:03 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e185so18239447pfg.23
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 08:10:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t62si7192893pfa.49.2018.01.18.08.10.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 08:10:01 -0800 (PST)
Date: Thu, 18 Jan 2018 17:07:50 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH v6 00/99] XArray version 6
Message-ID: <20180118160749.GP13726@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <20180117202203.19756-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

On Wed, Jan 17, 2018 at 12:20:24PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> This version of the XArray has no known bugs.

I've booted this patchset on 2 boxes, both had random problems during
boot. On one I was not able to diagnose what went wrong. On the other
one the system booted up to userspace and failed to set up networking.
Serial console worked and the network service complained about wrong
format of /usr/share/wicked/schema/team.xml . That's supposed to be a
text file, though hexdump showed me lots of zeros. Trimmed output:

00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
(similar output here)
*
00000a10  00 00 00 00 00 00 00 00  11 03 00 00 00 00 00 00  |................|
00000a20  20 8b 7f 01 00 00 00 00  a0 84 7d 01 00 00 00 00  | .........}.....|
00000a30  00 00 00 00 00 00 00 00  10 89 7f 01 00 00 00 00  |................|
00000a40  a0 84 7d 01 00 00 00 00  00 00 00 00 00 00 00 00  |..}.............|
00000a50  80 8a 7f 01 00 00 00 00  e0 cf 7d 01 00 00 00 00  |..........}.....|
00000a60  00 00 00 00 00 00 00 00  60 8a 7f 01 00 00 00 00  |........`.......|
00000a70  a0 84 7d 01 00 00 00 00  00 00 00 00 00 00 00 00  |..}.............|
00000a80  30 89 7f 01 00 00 00 00  a0 84 7d 01 00 00 00 00  |0.........}.....|
00000a90  00 00 00 00 00 00 00 00  60 f2 7f 01 00 00 00 00  |........`.......|
00000aa0  40 fd 7e 01 00 00 00 00  00 00 00 00 00 00 00 00  |@.~.............|
00000ab0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00001000  3e 0a 20 20 3c 2f 6d 65  74 68 6f 64 3e 0a 3c 2f  |>.  </method>.</|
00001010  73 65 72 76 69 63 65 3e  0a                       |service>.|

There's something at the end of the file that does look like a xml fragment.
The file size is 4121. This looks to me like exactly the first page of the file
was not read correctly.

The xml file is supposed to be read-only during startup, so there was no write
in flight. 'rpm -Vv' reported only this file corrupted. Booting to other
kernels was fine, network up, and the file was ok again. So the
corruption happened only in memory, which leads me to conclusion that
there is an unknown bug in your patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
