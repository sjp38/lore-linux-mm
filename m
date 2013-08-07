Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 221876B0032
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 13:40:54 -0400 (EDT)
Message-ID: <520286A4.1020101@intel.com>
Date: Wed, 07 Aug 2013 10:40:52 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/3] Add madvise(..., MADV_WILLWRITE)
References: <cover.1375729665.git.luto@amacapital.net> <20130807134058.GC12843@quack.suse.cz>
In-Reply-To: <20130807134058.GC12843@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org

On 08/07/2013 06:40 AM, Jan Kara wrote:
>   One question before I look at the patches: Why don't you use fallocate()
> in your application? The functionality you require seems to be pretty
> similar to it - writing to an already allocated block is usually quick.

One problem I've seen is that it still costs you a fault per-page to get
the PTEs in to a state where you can write to the memory.  MADV_WILLNEED
will do readahead to get the page cache filled, but it still leaves the
pages unmapped.  Those faults get expensive when you're trying to do a
couple hundred million of them all at once.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
