Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A4EFB6B0024
	for <linux-mm@kvack.org>; Fri,  6 May 2011 04:07:33 -0400 (EDT)
Date: Fri, 6 May 2011 09:07:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
Message-ID: <20110506080728.GC6591@suse.de>
References: <20110428171826.GZ4658@suse.de>
 <1304015436.2598.19.camel@mulgrave.site>
 <20110428192104.GA4658@suse.de>
 <1304020767.2598.21.camel@mulgrave.site>
 <1304025145.2598.24.camel@mulgrave.site>
 <1304030629.2598.42.camel@mulgrave.site>
 <20110503091320.GA4542@novell.com>
 <1304431982.2576.5.camel@mulgrave.site>
 <1304432553.2576.10.camel@mulgrave.site>
 <20110506074224.GB6591@suse.de>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Content-Disposition: inline
In-Reply-To: <20110506074224.GB6591@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@suse.de>
Cc: Mel Gorman <mgorman@novell.com>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

On Fri, May 06, 2011 at 08:42:24AM +0100, Mel Gorman wrote:
> 1. High-order allocations? You machine is using i915 and RPC, something
>    neither of my test machine uses. i915 is potentially a source for
>    high-order allocations. I'm attaching a perl script. Please run it as
>    ./watch-highorder.pl --output /tmp/highorders.txt
>    while you are running tar. When kswapd is running for about 30
>    seconds, interrupt it with ctrl+c twice in quick succession and
>    post /tmp/highorders.txt
> 

Attached this time :/

-- 
Mel Gorman
SUSE Labs

--oyUTqETQ0mS9luUI
Content-Type: application/x-perl
Content-Disposition: attachment; filename="watch-highorder.pl"
Content-Transfer-Encoding: quoted-printable

#!/usr/bin/perl=0A# This is a tool that analyses the trace output related t=
o page allocation,=0A# sums up the number of high-order allocations taking =
place and who the=0A# callers are=0A#=0A# Example usage: trace-pagealloc-hi=
ghorder.pl -o output-report.txt=0A# options=0A# -o, --output	Where to store=
 the report=0A#=0A# Copyright (c) IBM Corporation 2009=0A# Author: Mel Gorm=
an <mel@csn.ul.ie>=0Ause strict;=0Ause Getopt::Long;=0A=0A# Tracepoint even=
ts=0Ause constant MM_PAGE_ALLOC		=3D> 1;=0Ause constant EVENT_UNKNOWN		=3D>=
 7;=0A=0Ause constant HIGH_NORMAL_HIGHORDER_ALLOC	=3D> 10;=0Ause constant H=
IGH_ATOMIC_HIGHORDER_ALLOC	=3D> 11;=0A=0Amy $opt_output;=0Amy %stats;=0Amy =
%unique_events;=0Amy $last_updated =3D 0;=0A=0A$stats{HIGH_NORMAL_HIGHORDER=
_ALLOC} =3D 0;=0A$stats{HIGH_ATOMIC_HIGHORDER_ALLOC} =3D 0;=0A=0A# Catch si=
gint and exit on request=0Amy $sigint_report =3D 0;=0Amy $sigint_exit =3D 0=
;=0Amy $sigint_pending =3D 0;=0Amy $sigint_received =3D 0;=0Asub sigint_han=
dler {=0A	my $current_time =3D time;=0A	if ($current_time - 2 > $sigint_rec=
eived) {=0A		print "SIGINT received, report pending. Hit ctrl-c again to ex=
it\n";=0A		$sigint_report =3D 1;=0A	} else {=0A		if (!$sigint_exit) {=0A			=
print "Second SIGINT received quickly, exiting\n";=0A		}=0A		$sigint_exit++=
;=0A	}=0A=0A	if ($sigint_exit > 3) {=0A		print "Many SIGINTs received, exit=
ing now without report\n";=0A		exit;=0A	}=0A=0A	$sigint_received =3D $curre=
nt_time;=0A	$sigint_pending =3D 1;=0A}=0A$SIG{INT} =3D "sigint_handler";=0A=
=0A# Parse command line options=0AGetOptions(=0A	'output=3Ds'    =3D> \$opt=
_output,=0A);=0A=0A# Defaults for dynamically discovered regex's=0Amy $rege=
x_pagealloc_default =3D 'page=3D([0-9a-f]*) pfn=3D([0-9]*) order=3D([-0-9]*=
) migratetype=3D([-0-9]*) gfp_flags=3D([A-Z_|]*)';=0A=0A# Dyanically discov=
ered regex=0Amy $regex_pagealloc;=0A=0A# Static regex used. Specified like =
this for readability and for use with /o=0A#                      (process_=
pid)     (cpus      )   ( time  )   (tpoint    ) (details)=0Amy $regex_trac=
eevent =3D '\s*([a-zA-Z0-9-]*)\s*(\[[0-9]*\])\s*([0-9.]*):\s*([a-zA-Z_]*):\=
s*(.*)';=0Amy $regex_statname =3D '[-0-9]*\s\((.*)\).*';=0Amy $regex_statpp=
id =3D '[-0-9]*\s\(.*\)\s[A-Za-z]\s([0-9]*).*';=0A=0Asub generate_traceeven=
t_regex {=0A	my $event =3D shift;=0A	my $default =3D shift;=0A	my $regex;=
=0A=0A	# Read the event format or use the default=0A	if (!open (FORMAT, "/s=
ys/kernel/debug/tracing/events/$event/format")) {=0A		$regex =3D $default;=
=0A	} else {=0A		my $line;=0A		while (!eof(FORMAT)) {=0A			$line =3D <FORMA=
T>;=0A			if ($line =3D~ /^print fmt:\s"(.*)",.*/) {=0A				$regex =3D $1;=0A=
				$regex =3D~ s/%p/\([0-9a-f]*\)/g;=0A				$regex =3D~ s/%d/\([-0-9]*\)/g;=
=0A				$regex =3D~ s/%lu/\([0-9]*\)/g;=0A				$regex =3D~ s/%s/\([A-Z_|]*\)/=
g;=0A				$regex =3D~ s/\(REC->gfp_flags\).*/REC->gfp_flags/;=0A				$regex =
=3D~ s/\",.*//;=0A			}=0A		}=0A	}=0A=0A	# Verify fields are in the right or=
der=0A	my $tuple;=0A	foreach $tuple (split /\s/, $regex) {=0A		my ($key, $v=
alue) =3D split(/=3D/, $tuple);=0A		my $expected =3D shift;=0A		if ($key ne=
 $expected) {=0A			print("WARNING: Format not as expected '$key' !=3D '$exp=
ected'");=0A			$regex =3D~ s/$key=3D\((.*)\)/$key=3D$1/;=0A		}=0A	}=0A=0A	i=
f (defined shift) {=0A		die("Fewer fields than expected in format");=0A	}=
=0A=0A	return $regex;=0A}=0A$regex_pagealloc =3D generate_traceevent_regex(=
"kmem/mm_page_alloc",=0A			$regex_pagealloc_default,=0A			"page", "pfn",=0A=
			"order", "migratetype", "gfp_flags");=0A=0Asub process_events {=0A	my $t=
raceevent;=0A	my $process_pid =3D 0;=0A	my $cpus;=0A	my $timestamp;=0A	my $=
tracepoint;=0A	my $details;=0A	my $statline;=0A	my $nextline =3D 1;=0A=0A	#=
 Read each line of the event log=0AEVENT_PROCESS:=0A	while (($traceevent =
=3D <TRACING>) && !$sigint_exit) {=0ASKIP_LINEREAD:=0A=0A		if ($traceevent =
eq "") {=0A			last EVENT_PROCSS;=0A		}=0A=0A		if ($traceevent =3D~ /$regex_=
traceevent/o) {=0A			$process_pid =3D $1;=0A			$tracepoint =3D $4;=0A		} el=
se {=0A			next;=0A		}=0A=0A		# Perl Switch() sucks majorly=0A		if ($tracepo=
int eq "mm_page_alloc") {=0A			my ($page, $order, $gfp_flags, $type);=0A			=
my ($atomic);=0A			my $details =3D $5;=0A=0A			if ($details !~ /$regex_page=
alloc/o) {=0A				print "WARNING: Failed to parse mm_page_alloc as expected\=
n";=0A				print "$details\n";=0A				print "$regex_pagealloc\n";=0A				print=
 "\n";=0A				next;=0A			}=0A			$page =3D $1;=0A			$order =3D $3;=0A			$gfp_=
flags =3D $5;=0A=0A			# Only concerned with high-order allocs=0A			if ($ord=
er =3D=3D 0) {=0A				next;=0A			}=0A=0A			$stats{MM_PAGE_ALLOC}++;=0A=0A			=
if ($gfp_flags =3D~ /ATOMIC/) {=0A				$stats{HIGH_ATOMIC_HIGHORDER_ALLOC}++=
;=0A				$type =3D "atomic";=0A			} else {=0A				$stats{HIGH_NORMAL_HIGHORDE=
R_ALLOC}++;=0A				$type =3D "normal";=0A			}=0A=0A			# Record the stack tra=
ce=0A			$traceevent =3D <TRACING>;=0A			if ($traceevent !~ /stack trace/) {=
=0A				goto SKIP_LINEREAD;=0A			}=0A			my $event =3D "order=3D$order $type =
gfp_flags=3D$gfp_flags\n";;=0A			while ($traceevent =3D <TRACING>) {=0A				=
if ($traceevent !~ /^ =3D>/) {=0A					$unique_events{$event}++;=0A					my $=
current =3D time;=0A=0A					if ($current - $last_updated > 60) {=0A						$l=
ast_updated =3D $current;=0A						update_report();=0A					}=0A					goto SKI=
P_LINEREAD;=0A				}=0A				$event .=3D $traceevent;=0A			}=0A		} else {=0A		=
	$stats{EVENT_UNKNOWN}++;=0A		}=0A=0A		if ($sigint_pending) {=0A			last EVE=
NT_PROCESS;=0A		}=0A	}=0A}=0A=0Asub update_report() {=0A	my $event;=0A	open=
 (REPORT, ">$opt_output") || die ("Failed to open $opt_output for writing")=
;=0A=0A	foreach $event (keys %unique_events) {=0A		print REPORT $unique_eve=
nts{$event} . " instances $event\n";=0A	}=0A	print REPORT "High-order norma=
l allocations: " . $stats{HIGH_NORMAL_HIGHORDER_ALLOC} . "\n";=0A	print REP=
ORT "High-order atomic allocations: " . $stats{HIGH_ATOMIC_HIGHORDER_ALLOC}=
 . "\n";=0A=0A	close REPORT;=0A}=0A=0Asub print_report() {=0A	print "\nRepo=
rt\n";=0A	open (REPORT, $opt_output) || die ("Failed to open $opt_output fo=
r reading");=0A	while (<REPORT>) {=0A		print $_;=0A	}=0A	close REPORT;=0A}=
=0A=0A# Process events or signals until neither is available=0Asub signal_l=
oop() {=0A	my $sigint_processed;=0A	do {=0A		$sigint_processed =3D 0;=0A		p=
rocess_events();=0A=0A		# Handle pending signals if any=0A		if ($sigint_pen=
ding) {=0A			my $current_time =3D time;=0A=0A			if ($sigint_exit) {=0A				p=
rint "Received exit signal\n";=0A				$sigint_pending =3D 0;=0A			}=0A			if =
($sigint_report) {=0A				if ($current_time >=3D $sigint_received + 2) {=0A	=
				update_report();=0A					print_report();=0A					$sigint_report =3D 0;=0A=
					$sigint_pending =3D 0;=0A					$sigint_processed =3D 1;=0A					$sigint_=
exit =3D 0;=0A				}=0A			}=0A		}=0A	} while ($sigint_pending || $sigint_pro=
cessed);=0A}=0A=0Asub set_traceoption($) {=0A	my $option =3D shift;=0A=0A	o=
pen(TRACEOPT, ">/sys/kernel/debug/tracing/trace_options") || die("Failed to=
 open trace_options");=0A	print TRACEOPT $option;=0A	close TRACEOPT;=0A}=0A=
=0Asub enable_tracing($) {=0A	my $tracing =3D shift;=0A=0A	open(TRACING, ">=
/sys/kernel/debug/tracing/events/$tracing/enable") || die("Failed to open t=
racing event $tracing");=0A	print TRACING "1";=0A	close TRACING;=0A}=0A=0As=
ub disable_tracing($) {=0A	my $tracing =3D shift;=0A=0A	open(TRACING, ">/sy=
s/kernel/debug/tracing/events/$tracing/enable") || die("Failed to open trac=
ing event $tracing");=0A	print TRACING "0";=0A	close TRACING;=0A=0A}=0A=0As=
et_traceoption("stacktrace");=0Aset_traceoption("sym-offset");=0Aset_traceo=
ption("sym-addr");=0Aenable_tracing("kmem/mm_page_alloc");=0Aopen(TRACING, =
"/sys/kernel/debug/tracing/trace_pipe") || die("Failed to open trace_pipe")=
;=0Asignal_loop();=0Aclose TRACING;=0Adisable_tracing("kmem/mm_page_alloc")=
;=0Aupdate_report();=0Aprint_report();=0A=0A
--oyUTqETQ0mS9luUI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
