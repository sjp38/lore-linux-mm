Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 176086B01F7
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 11:01:01 -0400 (EDT)
Message-ID: <4BD1B626.7020702@redhat.com>
Date: Fri, 23 Apr 2010 18:00:54 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com> <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default> <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default> <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default 4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> <4BD1B427.9010905@redhat.com>
In-Reply-To: <4BD1B427.9010905@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/23/2010 05:52 PM, Avi Kivity wrote:
>
> I see.  So why not implement this as an ordinary swap device, with a 
> higher priority than the disk device?  this way we reuse an API and 
> keep things asynchronous, instead of introducing a special purpose API.
>

Ok, from your original post:

> An "init" prepares the pseudo-RAM to receive frontswap pages and returns
> a non-negative pool id, used for all swap device numbers (aka "type").
> A "put_page" will copy the page to pseudo-RAM and associate it with
> the type and offset associated with the page. A "get_page" will copy the
> page, if found, from pseudo-RAM into kernel memory, but will NOT remove
> the page from pseudo-RAM.  A "flush_page" will remove the page from
> pseudo-RAM and a "flush_area" will remove ALL pages associated with the
> swap type (e.g., like swapoff) and notify the pseudo-RAM device to refuse
> further puts with that swap type.
>
> Once a page is successfully put, a matching get on the page will always
> succeed.  So when the kernel finds itself in a situation where it needs
> to swap out a page, it first attempts to use frontswap.  If the put returns
> non-zero, the data has been successfully saved to pseudo-RAM and
> a disk write and, if the data is later read back, a disk read are avoided.
> If a put returns zero, pseudo-RAM has rejected the data, and the page can
> be written to swap as usual.
>
> Note that if a page is put and the page already exists in pseudo-RAM
> (a "duplicate" put), either the put succeeds and the data is overwritten,
> or the put fails AND the page is flushed.  This ensures stale data may
> never be obtained from pseudo-RAM.
>    

Looks like "init" == open, "put_page" == write, "get_page" == read, 
"flush_page|flush_area" == trim.  The only difference seems to be that 
an overwriting put_page may fail.  Doesn't seem to be much of a win, 
since a guest can simply avoid issuing the duplicate put_page, so the 
hypervisor is still committed to holding this memory for the guest.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
