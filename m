Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 567AD6B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 13:23:49 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 207so9940648iti.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 10:23:49 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0031.hostedemail.com. [216.40.44.31])
        by mx.google.com with ESMTPS id s6si3204821ioe.247.2017.12.14.10.23.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 10:23:48 -0800 (PST)
Message-ID: <1513275822.27409.73.camel@perches.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
From: Joe Perches <joe@perches.com>
Date: Thu, 14 Dec 2017 10:23:42 -0800
In-Reply-To: <20171211224301.GA3925@bombadil.infradead.org>
References: <fd7130d7-9066-524e-1053-a61eeb27cb36@lge.com>
	 <Pine.LNX.4.44L0.1712081228430.1371-100000@iolanthe.rowland.org>
	 <20171208223654.GP5858@dastard> <1512838818.26342.7.camel@perches.com>
	 <20171211214300.GT5858@dastard> <1513030348.3036.5.camel@perches.com>
	 <20171211224301.GA3925@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Alan Stern <stern@rowland.harvard.edu>, Byungchul Park <byungchul.park@lge.com>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Mon, 2017-12-11 at 14:43 -0800, Matthew Wilcox wrote:
>  - There's no warning for the first paragraph of section 6:
> 
> 6) Functions
> ------------
> 
> Functions should be short and sweet, and do just one thing.  They should
> fit on one or two screenfuls of text (the ISO/ANSI screen size is 80x24,
> as we all know), and do one thing and do that well.
> 
>    I'm not expecting you to be able to write a perl script that checks
>    the first line, but we have way too many 200-plus line functions in
>    the kernel.  I'd like a warning on anything over 200 lines (a factor
>    of 4 over Linus's stated goal).

Perhaps something like this?

(very very lightly tested, more testing appreciated)
---
 scripts/checkpatch.pl | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 4306b7616cdd..523aead40b87 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -59,6 +59,7 @@ my $conststructsfile = "$D/const_structs.checkpatch";
 my $typedefsfile = "";
 my $color = "auto";
 my $allow_c99_comments = 1;
+my $max_function_length = 200;
 
 sub help {
 	my ($exitcode) = @_;
@@ -2202,6 +2203,7 @@ sub process {
 	my $realcnt = 0;
 	my $here = '';
 	my $context_function;		#undef'd unless there's a known function
+	my $context_function_linenum;
 	my $in_comment = 0;
 	my $comment_edge = 0;
 	my $first_line = 0;
@@ -2341,6 +2343,7 @@ sub process {
 			} else {
 				undef $context_function;
 			}
+			undef $context_function_linenum;
 			next;
 
 # track the line number as we move through the hunk, note that
@@ -3200,11 +3203,18 @@ sub process {
 		if ($sline =~ /^\+\{\s*$/ &&
 		    $prevline =~ /^\+(?:(?:(?:$Storage|$Inline)\s*)*\s*$Type\s*)?($Ident)\(/) {
 			$context_function = $1;
+			$context_function_linenum = $realline;
 		}
 
 # check if this appears to be the end of function declaration
 		if ($sline =~ /^\+\}\s*$/) {
+			if (defined($context_function_linenum) &&
+			    ($realline - $context_function_linenum) > $max_function_length) {
+				WARN("LONG_FUNCTION",
+				     "'$context_function' function definition is " . ($realline - $context_function_linenum) . " lines, perhaps refactor\n" . $herecurr);
+			}
 			undef $context_function;
+			undef $context_function_linenum;
 		}
 
 # check indentation of any line with a bare else
@@ -5983,6 +5993,7 @@ sub process {
 		    defined $stat &&
 		    $stat =~ /^.\s*(?:$Storage\s+)?$Type\s*($Ident)\s*$balanced_parens\s*{/s) {
 			$context_function = $1;
+			$context_function_linenum = $realline;
 
 # check for multiline function definition with misplaced open brace
 			my $ok = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
