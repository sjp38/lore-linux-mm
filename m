Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 15A206B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 12:01:31 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p97Fw1AS011073
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 09:58:01 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p97G1A4M090216
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 10:01:11 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p97G1A88014885
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 10:01:10 -0600
Message-ID: <4E8F2242.3030406@linux.vnet.ibm.com>
Date: Fri, 07 Oct 2011 11:01:06 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] Re: RFC -- new zone type
References: <20110928180909.GA7007@labbmf-linux.qualcomm.comCAOFJiu1_HaboUMqtjowA2xKNmGviDE55GUV4OD1vN2hXUf4-kQ@mail.gmail.com> <c2d9add1-0095-4319-8936-db1b156559bf@default20111005165643.GE7007@labbmf-linux.qualcomm.com> <cc1256f9-4808-4d74-a321-6a3ec129cc05@default 20111006230348.GF7007@labbmf-linux.qualcomm.com> <4d0a5da4-00de-40dd-8d75-8ed6e3d0831c@default>
In-Reply-To: <4d0a5da4-00de-40dd-8d75-8ed6e3d0831c@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Larry Bassel <lbassel@codeaurora.org>, linux-mm@kvack.org, Xen-devel@lists.xensource.com

On 10/07/2011 10:23 AM, Dan Magenheimer wrote:
>> From: Larry Bassel [mailto:lbassel@codeaurora.org]
>> Sent: Thursday, October 06, 2011 5:04 PM
>> To: Dan Magenheimer
>> Cc: Larry Bassel; linux-mm@kvack.org; Xen-devel@lists.xensource.com
>> Subject: Re: [Xen-devel] Re: RFC -- new zone type
>>
>> Thanks for your answers to my questions. I have one more:
>>
>> Will there be any problem if the memory I want to be
>> transcendent is highmem (i.e. doesn't have any permanent
>> virtual<->physical mapping)?

I guess I need to make the distinction between tmem, the transcendent
memory layer, and zcache, a tmem backend that does the compression
and storage work.  Tmem is highmem agnostic.  It's just passing the
page information through to the backend, zcache.

Zcache can store data stored in highmem pages (after the patch that Dan
referred to), but can't use highmem pages in it's own storage pools.  Both
zbud (storage for compressed ephemeral pages) and xvmalloc (storage for
compressed persistent pages) don't set __GFP_HIGHMEM in their page
allocation calls because they return the virtual address of the page to
zcache.  Since highmem pages have no virtual address expect for the short
time they are mapped, this prevents highmem pages from being used by zbud
and xvmalloc.

I did write a patch a while back that allows xvmalloc to use highmem
pages in it's storage pool.  Although, from looking at the history of this
conversation, you'd be writing a different backend for tmem and not using
zcache anyway.

Currently the tmem code is in the zcache driver.  However, if there are
going to be other backends designed for it, we may need to move it into its
own module so it can be shared.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
