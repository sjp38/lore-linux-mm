Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 11FA96B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:16:48 -0400 (EDT)
Date: Fri, 7 Aug 2009 15:16:50 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/6] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
Message-ID: <20090807141650.GA24148@csn.ul.ie>
References: <1249574827-18745-1-git-send-email-mel@csn.ul.ie> <1249574827-18745-5-git-send-email-mel@csn.ul.ie> <20090807080018.GD20292@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090807080018.GD20292@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Fr?d?ric Weisbecker <fweisbec@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 07, 2009 at 10:00:18AM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > This patch adds a simple post-processing script for the 
> > page-allocator-related trace events. It can be used to give an 
> > indication of who the most allocator-intensive processes are and 
> > how often the zone lock was taken during the tracing period. 
> > Example output looks like
> 
> Note, this script hard-codes certain aspects of the output format:
> 

Yes, I noted that to some extent in the header with "The accuracy of the
parser may vary considerably" knowing that significant changes in the output
format would bust the script.

> +my $regex_traceevent =
> +'\s*([a-zA-Z0-9-]*)\s*(\[[0-9]*\])\s*([0-9.]*):\s*([a-zA-Z_]*):\s*(.*)';
> +my $regex_fragdetails = 'page=([0-9a-f]*) pfn=([0-9]*) alloc_order=([0-9]*)
> +fallback_order=([0-9]*) pageblock_order=([0-9]*) alloc_migratetype=([0-9]*)
> +fallback_migratetype=([0-9]*) fragmenting=([0-9]) change_ownership=([0-9])';
> +my $regex_statname = '[-0-9]*\s\((.*)\).*';
> +my $regex_statppid = '[-0-9]*\s\(.*\)\s[A-Za-z]\s([0-9]*).*';
> 
> the proper appproach is to parse /debug/tracing/events/mm/*/format. 
> That is why we emit a format string - to detach tools and reduce the 
> semi-ABI effect.
> 

Building a regularly expression is a tad messy but I can certainly do a
better job than currently. The information on every tracepoint seems
static so it doesn't need to be discovered but the trace format of the
details needs to be verified. I did the following and it should

o Ignore unrecognised fields in the middle of the format string
o Exit if expected fields do not exist
o It's not pasted, but it'll warn if the regex fails to match

Downsides include that I now hardcode the mount point of debugfs.

Basically, this can still break but it's more robust than it was.

# Defaults for dynamically discovered regex's
my $regex_fragdetails_default = 'page=([0-9a-f]*) pfn=([0-9]*) alloc_order=([-0-9]*) fallback_order=([-0-9]*) pageblock_order=([-0-9]*) alloc_migratetype=([-0-9]*) fallback_migratetype=([-0-9]*) fragmenting=([-0-9]) change_ownership=([-0-9])';

# Dyanically discovered regex
my $regex_fragdetails;

# Static regex used. Specified like this for readability and for use with /o
#                      (process_pid)     (cpus      )   ( time  )   (tpoint    ) (details)
my $regex_traceevent = '\s*([a-zA-Z0-9-]*)\s*(\[[0-9]*\])\s*([0-9.]*):\s*([a-zA-Z_]*):\s*(.*)';
my $regex_statname = '[-0-9]*\s\((.*)\).*';
my $regex_statppid = '[-0-9]*\s\(.*\)\s[A-Za-z]\s([0-9]*).*';

sub generate_traceevent_regex {
	my $event = shift;
	my $default = shift;
	my @fields = @_;
	my $regex;

	# Read the event format or use the default
	if (!open (FORMAT, "/sys/kernel/debug/tracing/events/$event/format")) {
		$regex = $default;
	} else {
		my $line;
		while (!eof(FORMAT)) {
			$line = <FORMAT>;
			if ($line =~ /^print fmt:\s"(.*)",.*/) {
				$regex = $1;
				$regex =~ s/%p/\([0-9a-f]*\)/g;
				$regex =~ s/%d/\([-0-9]*\)/g;
				$regex =~ s/%lu/\([0-9]*\)/g;
			}
		}
	}

	# Verify fields are in the right order
	my $tuple;
	foreach $tuple (split /\s/, $regex) {
		my ($key, $value) = split(/=/, $tuple);
		my $expected = shift;
		if ($key ne $expected) {
			print("WARNING: Format not as expected '$key' != '$expected'");
			$regex =~ s/$key=\((.*)\)/$key=$1/;
		}
	}
	if (defined $_) {
		die("Fewer fields than expected in format");
	}

	return $regex;
}
$regex_fragdetails = generate_traceevent_regex("kmem/mm_page_alloc_extfrag",
			$regex_fragdetails_default,
			"page", "pfn",
			"alloc_order", "fallback_order", "pageblock_order",
			"alloc_migratetype", "fallback_migratetype",
			"fragmenting", "change_ownership");


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
