Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 012C06B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 18:15:52 -0400 (EDT)
Message-ID: <4A493D19.4050908@goop.org>
Date: Mon, 29 Jun 2009 15:15:53 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC] transcendent memory for Linux
References: <a2cac9b3-74c1-4eea-8273-afe2226cef1d@default>
In-Reply-To: <a2cac9b3-74c1-4eea-8273-afe2226cef1d@default>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>
List-ID: <linux-mm.kvack.org>

On 06/29/09 14:57, Dan Magenheimer wrote:
> Interesting question.  But, more than the 128-bit UUID must
> be guessed... a valid 64-bit object id and a valid 32-bit
> page index must also be guessed (though most instances of
> the page index are small numbers so easy to guess).  Once
> 192 bits are guessed though, yes, the pages could be viewed
> and modified.  I suspect there are much more easily targeted
> security holes in most data centers than guessing 192 (or
> even 128) bits.
>   

If its possible to verify the uuid is valid before trying to find a
valid oid+page, then its much easier (since you can concentrate on the
uuid first).  If the uuid is derived from something like the
filesystem's uuid - which wouldn't normally be considered sensitive
information - then its not like its a search of the full 128-bit space. 
And even if it were secret, uuids are not generally 128 randomly chosen
bits.

You also have to consider the case of a domain which was once part of
the ocfs cluster, but now is not - it may still know the uuid, but not
be otherwise allowed to use the cluster.

> Now this only affects shared pools, and shared-precache is still
> experimental and not really part of this patchset.  Does "mount"
> of an accessible disk/filesystem have a better security model?
> Perhaps there are opportunities to leverage that?
>   

Well, a domain is allowed to access any block device you give it access
to.  I'm not sure what the equivalent model for tmem would be.

Anyway, it sounds like you need to think a fair bit more about shared
tmem's security model before it can be considered for use.

> Yes.  Perhaps all the non-flag bits should just be reserved for
> future use.  Today, the implementation just checks for (and implements)
> only zero anyway and nothing is defined anywhere except the 4K
> pagesize at the lowest levels of the (currently xen-only) API.
>   

Yes.  It should fail if it sees any unknown flags set in a guest request.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
