Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA7936B0038
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 18:05:16 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id u12so2756351uad.9
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 15:05:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a18sor7478361uad.120.2018.01.11.15.05.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 15:05:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180111170119.GB19241@thunk.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
 <1515636190-24061-14-git-send-email-keescook@chromium.org> <20180111170119.GB19241@thunk.org>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 11 Jan 2018 15:05:14 -0800
Message-ID: <CAGXu5jJ6=XXuCD7zm8NuKAy+-Ra3F2SyD+CVFjJ=-kQoXPty-A@mail.gmail.com>
Subject: Re: [PATCH 13/38] ext4: Define usercopy region in ext4_inode_cache
 slab cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, Andreas Dilger <adilger.kernel@dilger.ca>, Ext4 Developers List <linux-ext4@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com

On Thu, Jan 11, 2018 at 9:01 AM, Theodore Ts'o <tytso@mit.edu> wrote:
> On Wed, Jan 10, 2018 at 06:02:45PM -0800, Kees Cook wrote:
>> The ext4 symlink pathnames, stored in struct ext4_inode_info.i_data
>> and therefore contained in the ext4_inode_cache slab cache, need
>> to be copied to/from userspace.
>
> Symlink operations to/from userspace aren't common or in the hot path,
> and when they are in i_data, limited to at most 60 bytes.  Is it worth
> it to copy through a bounce buffer so as to disallow any usercopies
> into struct ext4_inode_info?

If this is the only place it's exposed, yeah, that might be a way to
avoid the per-FS patches. This would, AIUI, require changing
readlink_copy() to include a bounce buffer, and that would require an
allocation. I kind of prefer just leaving the per-FS whitelists, as
then there's no global overhead added.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
