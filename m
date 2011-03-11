Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C35EA8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 16:13:19 -0500 (EST)
Received: by qwa26 with SMTP id 26so114475qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:13:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1103111258340.31216@chino.kir.corp.google.com>
References: <AANLkTimU2QGc_BVxSWCN8GEhr8hCOi1Zp+eaA20_pE-w@mail.gmail.com>
	<alpine.DEB.2.00.1103111258340.31216@chino.kir.corp.google.com>
Date: Fri, 11 Mar 2011 21:13:18 +0000
Message-ID: <AANLkTimu-42CC3pv57njj6-UqwDO3iNLtiem9=y9ggng@mail.gmail.com>
Subject: Re: [RFC][PATCH 00/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

On Fri, Mar 11, 2011 at 9:01 PM, David Rientjes <rientjes@google.com> wrote=
:
> On Fri, 11 Mar 2011, Prasad Joshi wrote:
>
>> A filesystem might run into a problem while calling
>> __vmalloc(GFP_NOFS) inside a lock.
>>
>> It is expected than __vmalloc when called with GFP_NOFS should not
>> callback the filesystem code even incase of the increased memory
>> pressure. But the problem is that even if we pass this flag, __vmalloc
>> itself allocates memory with GFP_KERNEL.
>>
>> Using GFP_KERNEL allocations may go into the memory reclaim path and
>> try to free memory by calling file system clear_inode/evict_inode
>> function. Which might lead into deadlock.
>>
>> For further details
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D30702
>> http://marc.info/?l=3Dlinux-mm&m=3D128942194520631&w=3D4
>>
>> The patch passes the gfp allocation flag all the way down to those
>> allocating functions.
>>
>
> You're going to run into trouble by hard-wiring __GFP_REPEAT into all of
> the pte allocations because if GFP_NOFS is used then direct reclaim will
> usually fail (see the comment for do_try_to_free_pages(): If the caller i=
s
> !__GFP_FS then the probability of a failure is reasonably high) and, if
> it does so continuously, then the page allocator will loop forever. =A0Th=
is
> bit should probably be moved a level higher in your architecture changes
> to the caller passing GFP_KERNEL.

Thanks a lot for your reply. I should have seen your mail before
sending 23 mails :(
I will make the changes suggested by you and will resend all of the
patches again.

Thanks and Regards,
Prasad

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
