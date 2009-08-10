Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7772F6B004D
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 03:41:46 -0400 (EDT)
Date: Mon, 10 Aug 2009 08:41:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/6] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
Message-ID: <20090810074145.GA1933@csn.ul.ie>
References: <1249666815-28784-1-git-send-email-mel@csn.ul.ie> <1249666815-28784-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.00.0908071154120.14649@mail.selltech.ca> <alpine.DEB.1.00.0908071228310.14726@mail.selltech.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0908071228310.14726@mail.selltech.ca>
Sender: owner-linux-mm@kvack.org
To: "Li, Ming Chun" <macli@brc.ubc.ca>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 07, 2009 at 12:32:34PM -0700, Li, Ming Chun wrote:
> On Fri, 7 Aug 2009, Li, Ming Chun wrote:
> 
> > On Fri, 7 Aug 2009, Mel Gorman wrote:
> > 
> > > +sub generate_traceevent_regex {
> > > +	my $event = shift;
> > > +	my $default = shift;
> > > +	my @fields = @_;
> > > +	my $regex;
> > 
> > You are using shift to retrieve parameters below, @fields is not used 
> > anywhere.
> > 

Correct, this can be removed. Initially, I was going to use an array but
shift was far neater. Forgot to cleanup afterwards.

> > > +
> > > +	# Read the event format or use the default
> > > +	if (!open (FORMAT, "/sys/kernel/debug/tracing/events/$event/format")) {
> > > +		$regex = $default;
> > > +	} else {
> > > +		my $line;
> > > +		while (!eof(FORMAT)) {
> > > +			$line = <FORMAT>;
> > > +			if ($line =~ /^print fmt:\s"(.*)",.*/) {
> > > +				$regex = $1;
> > > +				$regex =~ s/%p/\([0-9a-f]*\)/g;
> > > +				$regex =~ s/%d/\([-0-9]*\)/g;
> > > +				$regex =~ s/%lu/\([0-9]*\)/g;
> > > +			}
> > > +		}
> > > +	}
> > > +
> > > +	# Verify fields are in the right order
> > > +	my $tuple;
> > > +	foreach $tuple (split /\s/, $regex) {
> > > +		my ($key, $value) = split(/=/, $tuple);
> > > +		my $expected = shift;
> > > +		if ($key ne $expected) {
> > > +			print("WARNING: Format not as expected '$key' != '$expected'");
> > > +			$regex =~ s/$key=\((.*)\)/$key=$1/;
> > > +		}
> > > +	}
> > > +	if (defined $_) {
> > > +		die("Fewer fields than expected in format");
> > > +	}
> > > +
> > 
> > How about:
> > 	if (defined shift) {
> > 		die("Fewer fields than expected in format");
> > 	}
> > ? 
> > 
> > I don't know, just ask if it is clear.
> 
> Ah, I think it should be:
> 	if (@_) {
> 		die("Fewer fields than expected in format");
> 	}
> 
> ? Sorry for the noise :)
> 

It's not noise at all, you're right to point out something was wrong
here. It needed to be either

if (defined shift)
if (defined $_[0])

I went with your first suggestion of "if (defined shift)"

Thanks

==== CUT HERE ====
tracing, page-allocator: Fix sanity check of TP_printk format for mm_page_alloc_extfrag

The trace-pagealloc-postprocess.pl script sanity checks the TP_printk
format for mm_page_alloc_extfrag to ensure all expected fields are in
the output format. Ming Chun Li pointed out that the check for all
expected fields is checking the wrong scalar and that there was a
unused @fields declared. This patch deletes the unused variable and
fixes the check.

Reported-by: Ming Chun Li <macli@brc.ubc.ca>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 Documentation/trace/postprocess/trace-pagealloc-postprocess.pl |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl b/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl
index 1a8a408..7df50e8 100755
--- a/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl
+++ b/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl
@@ -91,7 +91,6 @@ my $regex_statppid = '[-0-9]*\s\(.*\)\s[A-Za-z]\s([0-9]*).*';
 sub generate_traceevent_regex {
 	my $event = shift;
 	my $default = shift;
-	my @fields = @_;
 	my $regex;
 
 	# Read the event format or use the default
@@ -120,7 +119,8 @@ sub generate_traceevent_regex {
 			$regex =~ s/$key=\((.*)\)/$key=$1/;
 		}
 	}
-	if (defined $_) {
+
+	if (defined shift) {
 		die("Fewer fields than expected in format");
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
