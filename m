Date: Wed, 14 May 2003 08:06:53 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <20030514150653.GM8978@holomorphy.com>
References: <154080000.1052858685@baldur.austin.ibm.com> <20030513181018.4cbff906.akpm@digeo.com> <18240000.1052924530@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18240000.1052924530@baldur.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday, May 13, 2003 18:10:18 -0700 Andrew Morton <akpm@digeo.com> wrote:
>> That's the one.  Process is sleeping on I/O in filemap_nopage(), wakes up
>> after the truncate has done its thing and the page gets instantiated in
>> pagetables.
>> But it's an anon page now.  So the application (which was racy anyway)
>> gets itself an anonymous page.

On Wed, May 14, 2003 at 10:02:10AM -0500, Dave McCracken wrote:
> Which the application thinks is still part of the file, and will expect its
> changes to be written back.  Granted, if the page fault occurred just after
> the truncate it'd get SIGBUS, so it's clearly not a robust assumption, but
> it will result in unexpected behavior.  Note that if the application later
> extends the file to include this page it could result in a corrupted file,
> since all the pages around it will be written properly.

Well, for this one I'd say the app loses; it was its own failure to
synchronize truncation vs. access, at least given that the kernel
doesn't oops.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
