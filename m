Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5PIiELH095206
	for <linux-mm@kvack.org>; Tue, 26 Jun 2007 04:44:14 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5PIPjld189038
	for <linux-mm@kvack.org>; Tue, 26 Jun 2007 04:25:45 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5PIMDMD008576
	for <linux-mm@kvack.org>; Tue, 26 Jun 2007 04:22:13 +1000
Message-ID: <468007CB.7090003@linux.vnet.ibm.com>
Date: Mon, 25 Jun 2007 23:52:03 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm-controller
References: <1182418364.21117.134.camel@twins> <467A5B1F.5080204@linux.vnet.ibm.com>  <1182433855.21117.160.camel@twins> <467BFA47.4050802@linux.vnet.ibm.com> <6599ad830706251035t37f916dcr5e35e40e3470482c@mail.gmail.com> <6599ad830706251036i43fd6069x9b4191cb672b4f21@mail.gmail.com>
In-Reply-To: <6599ad830706251036i43fd6069x9b4191cb672b4f21@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, balbir@linux.vnet.ibm.com, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>, Pavel Emelianov <xemul@sw.ru>, Kirill Korotaev <dev@sw.ru>, devel@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>, Roy Huang <royhuang9@gmail.com>, Aubrey Li <aubreylee@gmail.com>
List-ID: <linux-mm.kvack.org>


Paul Menage wrote:
> On 6/25/07, Paul Menage <menage@google.com> wrote:
>> On 6/22/07, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com> wrote:
>>> Merging both limits will eliminate the issue, however we would need
>>> individual limits for pagecache and RSS for better control.  There are
>>> use cases for pagecache_limit alone without RSS_limit like the case of
>>> database application using direct IO, backup applications and
>>> streaming applications that does not make good use of pagecache.
>>>
>> If streaming applications would otherwise litter the pagecache with
>> unwanted data, then limiting their total memory footprint (with a
>> single limit) and forcing them to drop old data sooner sounds like a
>> great idea.
> 
> Actually, reading what you wrote more carefully, that's sort of what
> you were already saying. But it's not clear why you wouldn't also want
> to limit the anon pages for a job, if you're already concerned that
> it's not playing nicely with the rest of the system.

Hi Paul,

Limiting memory footprint (RSS and pagecache) for multi media
applications would work.  However, generally streaming applications
have a fairly constant RSS size (mapped pagecache pages + ANON) while
the unmapped pagecache pages is what we want to control better.

If we have a combined limit for unmapped pagecache pages and RSS, then
 we will have to bring in vm_swappiness kind of knobs for each
container to influence the per container reclaim process so as to not
hurt the application performance badly.

RSS controller should be able to take care of the mapped memory
footprint if needed.  In case of database server, moving out any of it
RSS pages will hurt it performance, while we are free to shrink the
unmapped pagecache pages to any smaller limit since the database is
using direct IO and does not benefit from pagecache.

With pagecache controller, we are able to split application's memory
pages into mapped and unmapped pages. Ability to account and control
unmapped pages in memory provides more possibilities for fine grain
resource management.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
