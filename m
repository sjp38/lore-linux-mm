Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 40D4F6B004A
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 11:45:02 -0400 (EDT)
Date: Wed, 15 Sep 2010 10:44:58 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC][PATCH] Cross Memory Attach
Message-ID: <20100915154458.GE3013@sgi.com>
References: <20100915104855.41de3ebf@lilo>
 <4C90A6C7.9050607@redhat.com>
 <20100916001232.0c496b02@lilo>
 <AANLkTikkAs5jUPhsq5=_Efv-MbbfCNmT10rcV6VUc54D@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTikkAs5jUPhsq5=_Efv-MbbfCNmT10rcV6VUc54D@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christopher Yeoh <cyeoh@au1.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> > 3. ability to map part of another process's address space directly into
> >   the current one. Would have setup/tear down overhead, but this would
> >   be useful specifically for reduction operations where we don't even
> >   need to really copy the data once at all, but use it directly in
> >   arithmetic/logical operations on the receiver.
> 
> Don't even think about this. If you want to map another tasks memory,
> use shared memory. The shared memory code knows about that. The races
> for anything else are crazy.

SGI has a similar, but significantly more difficult, problem to solve and
have written a fairly complex driver to handle exactly the scenario IBM
is proposing.  In our case, not only are we trying to directly access one
processes memory, we are doing it from a completely different operating
system instance operating on the same numa fabric.

In our case (I have not looked at IBMs patch), we are actually using
get_user_pages() to get extra references on struct pages.  We are
judicious about reference counting the mm and we use get_task_mm in all
places with the exception of process teardown (ignorable detail for now).
We have a fault handler inserting PFNs as appropriate.  You can guess
at the complexity.  Even with all its complexity, we still need to
caveat certain functionality as not being supported.

If we were to try and get that driver included in the kernel, how would
you suggest we expand the shared memory code to include support for the
coordination needed between those seperate operating system instances?
I am genuinely interested and not trying to be argumentative.  This has
been on my "Get done before Aug-1 list for months and I have not had
any time to pursue.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
