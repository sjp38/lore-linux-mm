Date: Wed, 15 Nov 2006 09:00:05 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: pagefault in generic_file_buffered_write() causing deadlock
Message-Id: <20061115090005.c9ec6db5.akpm@osdl.org>
In-Reply-To: <1163606265.7662.8.camel@dyn9047017100.beaverton.ibm.com>
References: <1163606265.7662.8.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, ext4 <linux-ext4@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Nov 2006 07:57:45 -0800
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> We are looking at a customer situation (on 2.6.16-based distro) - where
> system becomes almost useless while running some java & stress tests.
> 
> Root cause seems to be taking a pagefault in generic_file_buffered_write
> () after calling prepare_write. I am wondering 
> 
> 1) Why & How this can happen - since we made sure to fault the user
> buffer before prepare write.

When using writev() we only fault in the first segment of the iovec.  If
the second or succesive segment isn't mapped into pagetables we're
vulnerable to the deadlock.

> 2) If this is already fixed in current mainline (I can't see how).

It was fixed in 2.6.17.

You'll need 6527c2bdf1f833cc18e8f42bd97973d583e4aa83 and
81b0c8713385ce1b1b9058e916edcf9561ad76d6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
