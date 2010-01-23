Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A81936B006A
	for <linux-mm@kvack.org>; Sat, 23 Jan 2010 03:21:04 -0500 (EST)
Received: by iwn41 with SMTP id 41so1605013iwn.12
        for <linux-mm@kvack.org>; Sat, 23 Jan 2010 00:21:07 -0800 (PST)
Subject: Re: [RFC PATCH -tip 2/2 v2] add a scripts for pagecache usage per
 process
From: Tom Zanussi <tzanussi@gmail.com>
In-Reply-To: <4B5A3E19.6060502@bx.jp.nec.com>
References: <4B5A3D00.8080901@bx.jp.nec.com>
	 <4B5A3E19.6060502@bx.jp.nec.com>
Content-Type: text/plain
Date: Sat, 23 Jan 2010 02:21:05 -0600
Message-Id: <1264234865.6595.75.camel@tropicana>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Keiichi KII <k-keiichi@bx.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, lwoodman@redhat.com, linux-mm@kvack.org, mingo@elte.hu, riel@redhat.com, rostedt@goodmis.org, akpm@linux-foundation.org, fweisbec@gmail.com, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 2010-01-22 at 19:08 -0500, Keiichi KII wrote:
> The scripts are implemented based on the trace stream scripting support.
> And the scripts implement the following.
>  - how many pagecaches each process has per each file
>  - how many pages are cached per each file
>  - how many pagecaches each process shares
> 

Nice, it looks like a very useful script - I gave it a quick try and it
seems to work well...

The only problem I see, nothing to do with your script and nothing you
can do anything about at the moment, is that the record step generates a
huge amount of data, which of course makes the event processing take
awhile.  A lot of it appears to be due to perf itself - being able to
filter out the perf-generated events in the kernel would make a big
difference, I think; you normally don't want to see those anyway...

BTW, I see that you did your first version in Python - not that you'd
want to redo it again, but just FYI I now have working Python support
that I'll be posting soon - I still have some small details to hammer
out, but if you have any other scripts in the pipeline, in a couple days
you'll be able to use Python instead if you want.

A few more small comments below...

> To monitor pagecache usage per a process, run "pagecache-usage-record" to
> record perf data for "pagecache-usage.pl" and run "pagecache-usage-report"
> to display.

Another way of course would be to use 'perf trace record/report' and the
script name as shown by perf trace -l:

$ perf trace record pagecache-usage
$ perf trace report pagecache-usage

> 
> The below outputs show execution sample.
> 
> [file list]
>         device      inode   caches
>   --------------------------------
>          253:0    1051413      130
>          253:0    1051399        2
>          253:0    1051414       44
>          253:0    1051417      154
> 
> [process list]
> o postmaster-2330
>                             cached    added  removed      indirect
>         device      inode    pages    pages    pages removed pages
>   ----------------------------------------------------------------
>          253:0    1051399        0        2        0             0
>          253:0    1051417      154        0        0             0
>          253:0    1051413      130        0        0             0
>          253:0    1051414       44        0        0             0
>   ----------------------------------------------------------------
>   total:                       337        2        0             0
> 
> >From the output, we can know some information like:
> 
> - if "added pages" > "cached pages" on process list then
>     It means repeating add/remove pagecache many times.
>   => Bad case for pagecache usage
> 
> - if "added pages" <= "cached pages" on process list then
>     It means no unnecessary I/O operations.
>   => Good case for pagecache usage.
> 
> - if "caches" on file list > 
>          sum "cached pages" per each file on process list then
>     It means there are unneccessary pagecaches in the memory. 
>   => Bad case for pagecache usage
> 
> Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> Cc: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
> ---
>  tools/perf/scripts/perl/bin/pagecache-usage-record |    7 
>  tools/perf/scripts/perl/bin/pagecache-usage-report |    6 
>  tools/perf/scripts/perl/pagecache-usage.pl         |  160 +++++++++++++++++++++
>  3 files changed, 173 insertions(+)
> 
> Index: linux-2.6-tip/tools/perf/scripts/perl/bin/pagecache-usage-record
> ===================================================================
> --- /dev/null
> +++ linux-2.6-tip/tools/perf/scripts/perl/bin/pagecache-usage-record
> @@ -0,0 +1,7 @@
> +#!/bin/bash
> +perf record -c 1 -f -a -M -R -e filemap:add_to_page_cache -e filemap:find_get_page -e filemap:remove_from_page_cache
> +
> +
> +
> +
> +
> Index: linux-2.6-tip/tools/perf/scripts/perl/bin/pagecache-usage-report
> ===================================================================
> --- /dev/null
> +++ linux-2.6-tip/tools/perf/scripts/perl/bin/pagecache-usage-report
> @@ -0,0 +1,6 @@
> +#!/bin/bash
> +# description: pagecache usage per process
> +perf trace -s ~/libexec/perf-core/scripts/perl/pagecache-usage.pl
> +
> +
> +
> Index: linux-2.6-tip/tools/perf/scripts/perl/pagecache-usage.pl
> ===================================================================
> --- /dev/null
> +++ linux-2.6-tip/tools/perf/scripts/perl/pagecache-usage.pl
> @@ -0,0 +1,160 @@
> +# perf trace event handlers, generated by perf trace -g perl

You might want to get rid of this and add a short description and your
name, if you want to take credit for it. ;-)

> +# Licensed under the terms of the GNU GPL License version 2
> +

> +# The common_* event handler fields are the most useful fields common to
> +# all events.  They don't necessarily correspond to the 'common_*' fields
> +# in the format files.  Those fields not available as handler params can
> +# be retrieved using Perl functions of the form common_*($context).
> +# See Context.pm for the list of available functions.
> +

You can get rid of this part too - it's just meant to be helpful
information generated when starting a script.

> +use lib "$ENV{'PERF_EXEC_PATH'}/scripts/perl/Perf-Trace-Util/lib";
> +use lib "./Perf-Trace-Util/lib";
> +use Perf::Trace::Core;
> +use Perf::Trace::Context;
> +use Perf::Trace::Util;
> +use List::Util qw/sum/;
> +my %files;
> +my %processes;
> +my %records;
> +
> +sub trace_end
> +{
> +	print_pagecache_usage_per_file();
> +	print "\n";
> +	print_pagecache_usage_per_process();
> +	print_unhandled();
> +}
> +
> +sub filemap::remove_from_page_cache
> +{
> +	my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
> +	    $common_pid, $common_comm,
> +	    $s_dev, $i_ino, $offset) = @_;
> +	my $f = \%{$files{$s_dev}{$i_ino}};
> +	my $r = \%{$records{$common_comm."-".$common_pid}{$f}};
> +
> +	delete $$f{$offset};
> +	$$r{inode} = $i_ino;
> +	$$r{dev} = $s_dev;
> +	if (exists $$r{added}{$offset}) {
> +	    $$r{removed}++;
> +	} else {
> +	    $$r{indirect_removed}++;
> +	}
> +}
> +
> +sub filemap::add_to_page_cache
> +{
> +	my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
> +	    $common_pid, $common_comm,
> +	    $s_dev, $i_ino, $offset) = @_;
> +	my $f = \%{$files{$s_dev}{$i_ino}};
> +	my $r = \%{$records{$common_comm."-".$common_pid}{$f}};
> +
> +	$$f{$offset}++;
> +	$$r{added}{$offset}++;
> +	$$r{inode} = $i_ino;
> +	$$r{dev} = $s_dev;
> +}
> +
> +sub filemap::find_get_page
> +{
> +	my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
> +	    $common_pid, $common_comm,
> +	    $s_dev, $i_ino, $offset, $page) = @_;
> +	my $f = \%{$files{$s_dev}{$i_ino}};
> +	my $r = \%{$records{$common_comm."-".$common_pid}{$f}};
> +
> +	if ($page != 0) {
> +	    $$f{$offset}++;
> +	    $$r{cached}++;
> +	    $$r{inode} = $i_ino;
> +	    $$r{dev} = $s_dev;
> +	}
> +}
> +
> +my %unhandled;
> +
> +sub trace_unhandled
> +{
> +	my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
> +	    $common_pid, $common_comm) = @_;
> +
> +	$unhandled{$event_name}++;
> +}
> +
> +sub print_unhandled
> +{
> +	if ((scalar keys %unhandled) == 0) {
> +	    print "unhandled events nothing\n";

This is kind of distracting - it's not too useful to know that you don't
have unhandled events, but if you do have some, it is useful to print
those as you do below - it points out that some event type are being
unnecessarily recorded or the script is being run on the wrong trace
data.

Thanks,

Tom

> +	    return;
> +	}
> +
> +	print "\nunhandled events:\n\n";
> +
> +	printf("%-40s  %10s\n", "event", "count");
> +	printf("%-40s  %10s\n", "----------------------------------------",
> +	       "-----------");
> +
> +	foreach my $event_name (keys %unhandled) {
> +	    printf("%-40s  %10d\n", $event_name, $unhandled{$event_name});
> +	}
> +}
> +
> +sub minor
> +{
> +	my $dev = shift;
> +	return $dev & ((1 << 20) - 1);
> +}
> +
> +sub major
> +{
> +	my $dev = shift;
> +	return $dev >> 20;
> +}
> +
> +sub print_pagecache_usage_per_file
> +{
> +	print "[file list]\n";
> +	printf("  %12s %10s %8s\n", "", "", "cached");
> +	printf("  %12s %10s %8s\n", "device", "inode", "pages");
> +	printf("  %s\n", '-' x 32);
> +	while(my($dev, $file) = each(%files)) {
> +	    while(my($inode, $r) = each(%$file)) {
> +		my $count = values %$r;
> +		next if $count == 0;
> +		printf("  %12s %10d %8d\n",
> +		       major($dev).":".minor($dev), $inode, $count);
> +	    }
> +	}
> +}
> +
> +sub print_pagecache_usage_per_process
> +{
> +	print "[process list]\n";
> +	while(my ($pid, $v) = each(%records)) {
> +	    my ($sum_cached, $sum_added, $sum_removed, $sum_indirect_removed);
> +
> +	    print "o $pid\n";
> +	    printf("  %12s %10s %8s %8s %8s %13s\n", "", "",
> +		   "cached", "added", "removed", "indirect");
> +	    printf("  %12s %10s %8s %8s %8s %13s\n", "device", "inode",
> +		   "pages", "pages", "pages", "removed pages");
> +	    printf("  %s\n", '-' x 64);
> +	    while(my ($file, $r) = each(%$v)) {
> +		my $added_num = List::Util::sum(values %{$$r{added}});
> +		$sum_cached += $$r{cached};
> +		$sum_added += $added_num;
> +		$sum_removed += $$r{removed};
> +		$sum_indirect_removed += $$r{indirect_removed};
> +		printf("  %12s %10d %8d %8d %8d %13d\n",
> +		       major($$r{dev}).":".minor($$r{dev}), $$r{inode},
> +		       $$r{cached}, $added_num, $$r{removed},
> +		       $$r{indirect_removed});
> +	    }
> +	    printf("  %s\n", '-' x 64);
> +	    printf("  total: %5s %10s %8d %8d %8d %13d\n", "", "", $sum_cached,
> +		   $sum_added, $sum_removed, $sum_indirect_removed);
> +	    print "\n";
> +	}
> +}
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
