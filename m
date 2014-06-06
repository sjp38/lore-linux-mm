Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 818FA6B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 05:16:21 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id q59so2541209wes.10
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 02:16:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s1si46278714wiw.15.2014.06.06.02.16.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 02:16:20 -0700 (PDT)
Date: Fri, 6 Jun 2014 11:16:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
Message-ID: <20140606091620.GC26253@dhcp22.suse.cz>
References: <53905594d284f_71f12992fc6a@nysa.notmuch>
 <20140605133747.GB2942@dhcp22.suse.cz>
 <CAMP44s1kk8PyMd603g0C9yvHuuUZXzwwNQHpM8Abghvc_Os-SQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Content-Disposition: inline
In-Reply-To: <CAMP44s1kk8PyMd603g0C9yvHuuUZXzwwNQHpM8Abghvc_Os-SQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Felipe Contreras <felipe.contreras@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu 05-06-14 09:00:10, Felipe Contreras wrote:
> On Thu, Jun 5, 2014 at 8:37 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Thu 05-06-14 06:33:40, Felipe Contreras wrote:
> 
> >> For a while I've noticed that my machine bogs down in certain
> >> situations, usually while doing heavy I/O operations, it is not just the
> >> I/O operations, but everything, including the graphical interface, even
> >> the mouse pointer.
> >>
> >> As far as I can recall this did not happen in the past.
> >>
> >> I noticed this specially on certain operations, for example updating a
> >> a game on Steam (to an exteranl USB 3.0 device), or copying TV episodes
> >> to a USB memory stick (probably flash-based).
> >
> > We had a similar report for opensuse. The common part was that there was
> > an IO to a slow USB device going on.
> 
> Well, it's a USB 3.0 device, I can write at 250 MB/s, so it's not
> really that slow.
> 
> And in fact, when I read and write to and from the same USB 3.0
> device, I don't see the issue.
> 
> >> Then I went back to the latest stable version (v3.14.5), and commented
> >> out the line I think is causing the slow down:
> >>
> >>   if (nr_unqueued_dirty == nr_taken || nr_immediate)
> >>         congestion_wait(BLK_RW_ASYNC, HZ/10);
> >
> > Yes, I came to the same check. I didn't have any confirmation yet so
> > thanks for your confirmation. I've suggested to reduce this
> > congestion_wait only to kswapd:
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 32c661d66a45..ef6a1c0e788c 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1566,7 +1566,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >                  * implies that pages are cycling through the LRU faster than
> >                  * they are written so also forcibly stall.
> >                  */
> > -               if (nr_unqueued_dirty == nr_taken || nr_immediate)
> > +               if ((nr_unqueued_dirty == nr_taken || nr_immediate) && current_is_kswapd())
> >                         congestion_wait(BLK_RW_ASYNC, HZ/10);
> >         }
> 
> Unfortunately that doesn't fix the issue for me.

That is really interesting. So removing the test completely helps but
reducing it to kswapd doesn't. I would expect stalls coming from direct
reclaimers not the kswapd.

Mel has a nice systemtap script (attached) to watch for stalls. Maybe
you can give it a try?

-- 
Michal Hocko
SUSE Labs

--CE+1k2dSO48ffgeK
Content-Type: text/x-perl; charset=us-ascii
Content-Disposition: attachment; filename="watch-dstate-new.pl"

#!/usr/bin/perl
# This script is a combined perl and systemtap script to collect information
# on a system stalling in writeback. Ordinarily, one would expect that all
# information be collected in a STAP script. Unfortunately, in practice the
# stack unwinder in systemtap may not work with a current kernel version,
# have trouble collecting all the data necessary or some other oddities.
# Hence this hack. A systemtap script is run and as it records interesting
# events, the remaining information is collected from the script. This means
# that the data is *never* exact but can be better than nothing and easier
# than a fully manual check
#
# Copyright Mel Gorman <mgorman@suse.de> 2011

use File::Temp qw/mkstemp/;
use File::Find;
use FindBin qw($Bin);
use Getopt::Long;
use strict;

my @trace_functions = (
	# "get_request_wait" is now special cased unfortunately
	"wait_for_completion",
	"wait_on_page_bit",
	"wait_on_page_bit_killable",
	"try_to_free_pages"
	);

my @completion_functions=(
	"handle_mm_fault",
	"sys_select",
	"__wake_up",
	"wake_up_bit",
	"__alloc_pages_nodemask",
	"balance_pgdat",
	"kmem_cache_alloc");

my @trace_conditional = (
	"sync_page",
	"sync_buffer",
	"sleep_on_buffer",
	"try_to_compact_pages",
	"balance_dirty_pages_ratelimited_nr",
	"balance_dirty_pages",
	);

# Information on each stall is gathered and stored in a hash table for
# dumping later. Define some constants for the table lookup to avoid
# blinding headaches
use constant VMSTAT_AT_STALL       => 0;
use constant VMSTAT_AT_COMPLETE    => 1;
use constant BLOCKSTAT_AT_STALL    => 2;
use constant BLOCKSTAT_AT_COMPLETE => 3;
use constant PROCNAME              => 4;
use constant STACKTRACE            => 5;
use constant STALLFUNCTION         => 6;

use constant NR_WRITEBACK => 0;
use constant NR_DIRTY     => 2;
use constant VMSCAN_WRITE => 1;

sub usage() {
	print("In general, this script is not supported and that includes help.\n");
	exit(0);
}

# Option variables
my $opt_help;
my $opt_output;
my $opt_stapout;
my $opt_accurate_stall = 1;
my $opt_accurate_stack = 0;
GetOptions(
	'help|h'		=> \$opt_help,
	'output|o=s'		=> \$opt_output,
	'stapout|s=s'		=> \$opt_stapout,
	'accurate-stack|a'	=> \$opt_accurate_stack,
	'accurate-stall|a'	=> \$opt_accurate_stall,
);

usage() if $opt_help;
if ($opt_output) {
	open(OUTPUT, ">$opt_output") || die("Failed to open $opt_output for writing");
}
if ($opt_stapout) {
	open(OUTPUT, ">$opt_stapout") || die("Failed to open $opt_stapout for writing");
}

if ($opt_accurate_stack) {
	$opt_accurate_stall = 0;
}
if ($opt_accurate_stall) {
	$opt_accurate_stack = 0;
}

# Handle cleanup of temp files
my $stappid;
my ($handle, $stapscript) = mkstemp("/tmp/stapdXXXXX");
sub cleanup {
	if (defined($stappid)) {
		kill INT => $stappid;
	}
	if (defined($opt_output)) {
		close(OUTPUT);
	}
	unlink($stapscript);
}
sub sigint_handler {
	close(STAP);
	cleanup();
	exit(0);
}
$SIG{INT} = "sigint_handler";

# Build a list of stat files to read. Obviously this is not great if device
# hotplug occurs but that is not expected for the moment and this is lighter
# than running find every time
my @block_iostat_files;
sub d {
	my $file = $File::Find::name;
	return if $file eq "/sys/block";
	push(@block_iostat_files, "$file/stat");
}
find(\&d, ("/sys/block/"));

##
# Read the current stack of a given pid
sub read_stacktrace($) {
	open(STACK, "/proc/$_[0]/stack") || return "Stack unavailable";
	my $stack = do {
		local $/;
		<STACK>;
	};
	close(STACK);
	return $stack;
}

##
# Read information of relevant from /proc/vmstat
sub read_vmstat {
	if (!open(VMSTAT, "/proc/vmstat")) {
		cleanup();
		die("Failed to read /proc/vmstat");
	}

	my $vmstat;
	my ($key, $value);
	my @values;
	while (!eof(VMSTAT)) {
		$vmstat = <VMSTAT>;
		($key, $value) = split(/\s+/, $vmstat);
		chomp($value);

		if ($key eq "nr_writeback") {
			$values[NR_WRITEBACK] = $value;
		}
		if ($key eq "nr_dirty") {
			$values[NR_DIRTY] = $value;
		}
		if ($key eq "nr_vmscan_write") {
			$values[VMSCAN_WRITE] = $value;
		}
	}

	return \@values;
}

##
# Read information from all /sys/block stat files
sub read_blockstat($) {
	my $prefix = $_[0];
	my $stat;
	my $ret;
	
	foreach $stat (@block_iostat_files) {
		if (open(STAT, $stat)) {
			$ret .= sprintf "%s%20s %s", $prefix, $stat, <STAT>;
			close(STAT);
		}
	}
	return $ret;
}

##
# Record a line of output
sub log_output {
	if (defined($opt_output)) {
		print OUTPUT @_;
	}
	print @_;
}

sub log_printf {
	if (defined($opt_output)) {
		printf OUTPUT @_;
	}
	printf @_;
}

sub log_stap {
	if (defined($opt_stapout)) {
		print OUTPUT @_;
	}
}

# Crude as hell, do not really care
my %found_alts;
sub search_kallsyms {
	my @search_symbols = @_;

	# Read kernel symbols and add conditional trace functions if they exist
	open(KALLSYMS, "/proc/kallsyms") || die("Failed to open /proc/kallsyms");
	while (<KALLSYMS>) {
		my ($dummy, $dummy, $symbol) = split(/\s+/, $_);
		my $conditional;
		if ($symbol eq "get_request_wait" || $symbol eq "shrink_zone") {
			push(@trace_functions, $symbol);
			$found_alts{$symbol} = 1;
			next;
		}
		foreach $conditional (@search_symbols) {
			if ($symbol eq $conditional) {
				push(@trace_functions, $symbol);
				last;
			}
		}
	}
	close(KALLSYMS);
}
search_kallsyms(@trace_conditional);
if ($found_alts{"get_request_wait"} != 1) {
	push(@trace_functions, "get_request");
}

if ($found_alts{"shrink_zone"} != 1) {
	my @alt_shrinks = ("shrink_zones",
			"kswapd_shrink_zone",
			"__zone_reclaim",
			"balance_pgdat");
	search_kallsyms(@alt_shrinks);
}

# Extract the framework script and fill in the rest
open(SELF, "$0") || die("Failed to open running script");
while (<SELF>) {
	chomp($_);
	if ($_ ne "__END__") {
		next;
	}
	while (<SELF>) {
		print $handle $_;
	}
}
foreach(@trace_functions) {
	print $handle "probe kprobe.function(\"$_\")
{ 
	t=tid()
	name[t]=execname()
	stalled_at[t]=time()
	where[t]=\"$_\"
	delete stalled[t]
}";
}

if ($opt_accurate_stall) {
	# In an ideal world, we would always use a retprobe to catch exactly when
	# the function exited and get a stall time from it. Unfortunately, it mangles
	# the stack trace so we have the option of either accurately tracking stalls
	# or accurately tracking stacks
	foreach(@trace_functions) {
		print $handle "probe kprobe.function(\"$_\").return
{
	t=tid()

	if ([t] in stalled) {
		stall_time = time() - stalled_at[t]
		printf(\"C %d (%s) %d %s %s\\n\", t, name[t], stall_time, time_units, where[t])
	}

	delete stalled[t]
	delete name[t]
	delete stalled_at[t]
	delete where[t]
}"
	}
} else {
	# Alternatively, we try to catch when a stall completes by probing
	# commonly used functions and guessing that when they are called
	# that the operation completed
	foreach(@completion_functions) {
		print $handle "probe kprobe.function(\"$_\").return
{
	t=tid()

	if ([t] in stalled) {
		stall_time = time() - stalled_at[t]
		printf(\"C %d (%s) %d %s %s\\n\", t, name[t], stall_time, time_units, where[t])
	}

	delete stalled[t]
	delete name[t]
	delete stalled_at[t]
	delete where[t]
}";
	}
}

close($handle);

# Contact
$stappid = open(STAP, "stap $stapscript|");
if (!defined($stappid)) {
	die("Failed to execute stap script");
}

# Collect information until interrupted
my %stalled;
while (1) {
	if (eof(STAP)) {
		cleanup();
		die("Unexpected exit of STAP script");
	}

	my $input = <STAP>;
	log_stap($input);
	if ($input !~ /([CS]) ([0-9]*) \((.*)\) ([0-9]*) ms (.*)/) {
		cleanup();
		die("Failed to parse input from stap script\n");
	}

	my $event    = $1;
	my $pid      = $2;
	my $name     = $3;
	my $stalled  = $4;
	my $where    = $5;
	my $recursed = 0;
	
	# Check if we have recursively stalled. This is "impossible" but unless
	# we are using kretprobes, we cannot reliable catch when stalls complete
	if (defined($stalled{$pid}->{NAME}) && $event eq "S") {
		$recursed = 1;
		if ($opt_accurate_stall) {
			cleanup();
			print("Apparently recursing, missing kretprobes.\n");
			print("Process:  $pid ($name)\n");
			print("Stalled:  " . $stalled{$pid}->{STALLFUNCTION} . "\n");
			print($stalled{$pid}->{STACKTRACE});
			print("Stalling: $where\n");
			exit(-1);
		}
	}

	# Record information related to stalls.
	if ($event eq "C" || $recursed) {
		if ($name ne $stalled{$pid}->{NAME}) {
			cleanup();
			die("Processes are changing their identity.");
		}
		if ($where ne $stalled{$pid}->{STALLFUNCTION}) {
			$recursed = 1;
			if ($opt_accurate_stall) {
				cleanup();
				die("The stalling function teleported.");
			}
		}

		# Do not event pretend the stall time is accurate
		if ($recursed) {
			$stalled = -1;
		}

		$stalled{$pid}->{VMSTAT_AT_COMPLETE} = read_vmstat();
		$stalled{$pid}->{BLOCKSTAT_AT_COMPLETE} = read_blockstat("+");
		my $delta_writeback    = $stalled{$pid}->{VMSTAT_AT_COMPLETE}[NR_WRITEBACK] - $stalled{$pid}->{VMSTAT_AT_STALL}[NR_WRITEBACK];
		my $delta_dirty        = $stalled{$pid}->{VMSTAT_AT_COMPLETE}[NR_DIRTY]     - $stalled{$pid}->{VMSTAT_AT_STALL}[NR_DIRTY];
		my $delta_vmscan_write = $stalled{$pid}->{VMSTAT_AT_COMPLETE}[VMSCAN_WRITE] - $stalled{$pid}->{VMSTAT_AT_STALL}[VMSCAN_WRITE];

		# Blind stab in the dark as to what is going on
		my $status;
		if ($where eq "balance_dirty_pages") {
			$status = "DirtyThrottled";
		} else {
			$status = "IO";
		}
		if ($delta_writeback < 0) {
			$status = "${status}_WritebackInProgress";
		}
		if ($delta_writeback > 0) {
			$status = "${status}_WritebackSlow";
		}

		log_output("time " . time() . ": $pid ($name) Stalled: $stalled ms: $where\n");
		log_output("Guessing: $status\n");
		log_printf("-%-15s %12d\n", "nr_dirty",        $stalled{$pid}->{VMSTAT_AT_STALL}[NR_DIRTY]);
		log_printf("-%-15s %12d\n", "nr_writeback",    $stalled{$pid}->{VMSTAT_AT_STALL}[NR_WRITEBACK]);
		log_printf("-%-15s %12d\n", "nr_vmscan_write", $stalled{$pid}->{VMSTAT_AT_STALL}[VMSCAN_WRITE]);
		log_printf("%s", $stalled{$pid}->{BLOCKSTAT_AT_STALL});
		log_printf("+%-15s %12d %12d\n", "nr_dirty",
			$stalled{$pid}->{VMSTAT_AT_COMPLETE}[NR_DIRTY], $delta_dirty);
		log_printf("+%-15s %12d %12d\n", "nr_writeback",
			$stalled{$pid}->{VMSTAT_AT_COMPLETE}[NR_WRITEBACK], $delta_writeback);
		log_printf("+%-15s %12d %12d\n", "nr_vmscan_write",
			$stalled{$pid}->{VMSTAT_AT_COMPLETE}[VMSCAN_WRITE],
			$delta_vmscan_write);
		log_printf("%s", $stalled{$pid}->{BLOCKSTAT_AT_COMPLETE});
		log_output($stalled{$pid}->{STACKTRACE});

		delete($stalled{$pid});
	}

	if ($event eq "S") {
		$stalled{$pid}->{NAME} = $name;
		$stalled{$pid}->{STACKTRACE} = read_stacktrace($pid);
		$stalled{$pid}->{VMSTAT_AT_STALL} = read_vmstat();
		$stalled{$pid}->{BLOCKSTAT_AT_STALL} = read_blockstat("-");
		$stalled{$pid}->{STALLFUNCTION} = $where;
	}
}

cleanup();
exit(0);
__END__
function time () { return gettimeofday_ms() }
global stall_threshold = 1000
global time_units = "ms"
global name, stalled_at, stalled, where

probe timer.profile {
	foreach (tid+ in stalled_at) {
		if ([tid] in stalled) continue

		stall_time = time() - stalled_at[tid]
		if (stall_time >= stall_threshold) {
			printf ("S %d (%s) %d %s %s\n", tid, name[tid], stall_time, time_units, where[tid])
			stalled[tid] = 1 # defer further reports to wakeup
		}
	}
}


--CE+1k2dSO48ffgeK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
