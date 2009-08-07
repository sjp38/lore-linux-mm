Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5E3AA6B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 14:48:40 -0400 (EDT)
Date: Fri, 7 Aug 2009 12:10:05 -0700 (PDT)
From: "Li, Ming Chun" <macli@brc.ubc.ca>
Subject: Re: [PATCH 4/6] tracing, page-allocator: Add a postprocessing script
 for page-allocator-related ftrace events
In-Reply-To: <1249666815-28784-5-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.00.0908071154120.14649@mail.selltech.ca>
References: <1249666815-28784-1-git-send-email-mel@csn.ul.ie> <1249666815-28784-5-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Aug 2009, Mel Gorman wrote:

> +sub generate_traceevent_regex {
> +	my $event = shift;
> +	my $default = shift;
> +	my @fields = @_;
> +	my $regex;

You are using shift to retrieve parameters below, @fields is not used 
anywhere.

> +
> +	# Read the event format or use the default
> +	if (!open (FORMAT, "/sys/kernel/debug/tracing/events/$event/format")) {
> +		$regex = $default;
> +	} else {
> +		my $line;
> +		while (!eof(FORMAT)) {
> +			$line = <FORMAT>;
> +			if ($line =~ /^print fmt:\s"(.*)",.*/) {
> +				$regex = $1;
> +				$regex =~ s/%p/\([0-9a-f]*\)/g;
> +				$regex =~ s/%d/\([-0-9]*\)/g;
> +				$regex =~ s/%lu/\([0-9]*\)/g;
> +			}
> +		}
> +	}
> +
> +	# Verify fields are in the right order
> +	my $tuple;
> +	foreach $tuple (split /\s/, $regex) {
> +		my ($key, $value) = split(/=/, $tuple);
> +		my $expected = shift;
> +		if ($key ne $expected) {
> +			print("WARNING: Format not as expected '$key' != '$expected'");
> +			$regex =~ s/$key=\((.*)\)/$key=$1/;
> +		}
> +	}
> +	if (defined $_) {
> +		die("Fewer fields than expected in format");
> +	}
> +

How about:
	if (defined shift) {
		die("Fewer fields than expected in format");
	}
? 

I don't know, just ask if it is clear.

> +	return $regex;
> +}


Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
