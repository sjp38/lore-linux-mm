Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4753382F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 04:46:31 -0500 (EST)
Received: by wimw2 with SMTP id w2so6273420wim.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 01:46:30 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id gc9si6959423wjb.57.2015.11.05.01.46.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 01:46:30 -0800 (PST)
Date: Thu, 5 Nov 2015 09:46:15 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
Message-ID: <20151105094615.GP8644@n2100.arm.linux.org.uk>
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Kees Cook <keescook@chromium.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 04, 2015 at 05:00:39PM -0800, Laura Abbott wrote:
> Currently, read only permissions are not being applied even
> when CONFIG_DEBUG_RODATA is set. This is because section_update
> uses current->mm for adjusting the page tables. current->mm
> need not be equivalent to the kernel version. Use pgd_offset_k
> to get the proper page directory for updating.

What are you trying to achieve here?  You can't use these functions
at run time (after the first thread has been spawned) to change
permissions, because there will be multiple copies of the kernel
section mappings, and those copies will not get updated.

In any case, this change will probably break kexec and ftrace, as
the running thread will no longer see the updated page tables.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
