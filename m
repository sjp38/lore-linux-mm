Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 866156B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 07:17:46 -0500 (EST)
Date: Tue, 14 Feb 2012 12:17:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug 42578] Kernel crash "Out of memory error by X" when using
 NTFS file system on external USB Hard drive
Message-ID: <20120214121742.GJ17917@csn.ul.ie>
References: <bug-42578-27@https.bugzilla.kernel.org/>
 <201201180922.q0I9MCYl032623@bugzilla.kernel.org>
 <20120119122448.1cce6e76.akpm@linux-foundation.org>
 <20120210163748.GR5796@csn.ul.ie>
 <4F354D51.7020408@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F354D51.7020408@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Stuart Foster <smf.linux@ntlworld.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Feb 10, 2012 at 12:01:05PM -0500, Rik van Riel wrote:
> On 02/10/2012 11:37 AM, Mel Gorman wrote:
> >On Thu, Jan 19, 2012 at 12:24:48PM -0800, Andrew Morton wrote:
> 
> >>I think it is was always wrong that we only strip buffer_heads when
> >>moving pages to the inactive list.  What happens if those 600MB of
> >>buffer_heads are all attached to inactive pages?
> >>
> >
> >I wondered the same thing myself. With some use-once logic, there is
> >no guarantee that they even get promoted to the active list in the
> >first place. It's "always" been like this but we've changed how pages gets
> >promoted quite a bit and this use case could have been easily missed.
> 
> It may be possible to also strip the buffer heads from
> pages when they are moved to the active list, in
> activate_page().
> 

It'd be possible but is that really the right thing to do? I am thinking
about when we call mark_page_accessed via touch_buffer, __find_get_block
etc. In those paths, is it not implied the buffer_heads are in active use
and releasing them would be counter-productive?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
