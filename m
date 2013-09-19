Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4D56C6B0031
	for <linux-mm@kvack.org>; Sun, 22 Sep 2013 17:47:59 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so2444722pdi.5
        for <linux-mm@kvack.org>; Sun, 22 Sep 2013 14:47:58 -0700 (PDT)
Date: Thu, 19 Sep 2013 12:13:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: doing lots of disk writes causes oom killer to kill processes
Message-ID: <20130919101357.GA20140@quack.suse.cz>
References: <CAJd=RBBbJMWox5yJaNzW_jUdDfKfWe-Y7d1riYdN6huQStxzcA@mail.gmail.com>
 <CAOMqctQyS2SFraqJpzE0sRFcihFpMHRhT+3QuZhxft=SUXYVDw@mail.gmail.com>
 <CAOMqctQ+XchmXk_Xno6ViAoZF-tHFPpDWoy7LVW1nooa+ywbmg@mail.gmail.com>
 <CAOMqctT2u7E0kwpm052B9pkNo4D=sYHO+Vk=P_TziUb5KvTMKA@mail.gmail.com>
 <20130917211317.GB6537@quack.suse.cz>
 <CAOMqctT5Wi_Y9ODAnoG-RQiO1oJ+yKR=LnF21swuupyLShL=+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="45Z9DzgjV8m4Oswq"
Content-Disposition: inline
In-Reply-To: <CAOMqctT5Wi_Y9ODAnoG-RQiO1oJ+yKR=LnF21swuupyLShL=+w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Suchanek <hramrach@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Hillf Danton <dhillf@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed 18-09-13 16:56:08, Michal Suchanek wrote:
> On 17 September 2013 23:13, Jan Kara <jack@suse.cz> wrote:
> >   Hello,
> >
> > On Tue 17-09-13 15:31:31, Michal Suchanek wrote:
> >> On 5 September 2013 12:12, Michal Suchanek <hramrach@gmail.com> wrote:
> >> > On 26 August 2013 15:51, Michal Suchanek <hramrach@gmail.com> wrote:
> >> >> On 12 March 2013 03:15, Hillf Danton <dhillf@gmail.com> wrote:
> >> >>>>On 11 March 2013 13:15, Michal Suchanek <hramrach@gmail.com> wrote:
> >> >>>>>On 8 February 2013 17:31, Michal Suchanek <hramrach@gmail.com> wrote:
> >> >>>>> Hello,
> >> >>>>>
> >> >>>>> I am dealing with VM disk images and performing something like wiping
> >> >>>>> free space to prepare image for compressing and storing on server or
> >> >>>>> copying it to external USB disk causes
> >> >>>>>
> >> >>>>> 1) system lockup in order of a few tens of seconds when all CPU cores
> >> >>>>> are 100% used by system and the machine is basicaly unusable
> >> >>>>>
> >> >>>>> 2) oom killer killing processes
> >> >>>>>
> >> >>>>> This all on system with 8G ram so there should be plenty space to work with.
> >> >>>>>
> >> >>>>> This happens with kernels 3.6.4 or 3.7.1
> >> >>>>>
> >> >>>>> With earlier kernel versions (some 3.0 or 3.2 kernels) this was not a
> >> >>>>> problem even with less ram.
> >> >>>>>
> >> >>>>> I have  vm.swappiness = 0 set for a long  time already.
> >> >>>>>
> >> >>>>>
> >> >>>>I did some testing with 3.7.1 and with swappiness as much as 75 the
> >> >>>>kernel still causes all cores to loop somewhere in system when writing
> >> >>>>lots of data to disk.
> >> >>>>
> >> >>>>With swappiness as much as 90 processes still get killed on large disk writes.
> >> >>>>
> >> >>>>Given that the max is 100 the interval in which mm works at all is
> >> >>>>going to be very narrow, less than 10% of the paramater range. This is
> >> >>>>a severe regression as is the cpu time consumed by the kernel.
> >> >>>>
> >> >>>>The io scheduler is the default cfq.
> >> >>>>
> >> >>>>If you have any idea what to try other than downgrading to an earlier
> >> >>>>unaffected kernel I would like to hear.
> >> >>>>
> >> >>> Can you try commit 3cf23841b4b7(mm/vmscan.c: avoid possible
> >> >>> deadlock caused by too_many_isolated())?
> >> >>>
> >> >>> Or try 3.8 and/or 3.9, additionally?
> >> >>>
> >> >>
> >> >> Hello,
> >> >>
> >> >> with deadline IO scheduler I experience this issue less often but it
> >> >> still happens.
> >> >>
> >> >> I am on 3.9.6 Debian kernel so 3.8 did not fix this problem.
> >> >>
> >> >> Do you have some idea what to log so that useful information about the
> >> >> lockup is gathered?
> >> >>
> >> >
> >> > This appears to be fixed in vanilla 3.11 kernel.
> >> >
> >> > I still get short intermittent lockups and cpu usage spikes up to 20%
> >> > on a core but nowhere near the minute+ long lockups with all cores
> >> > 100% on earlier kernels.
> >> >
> >>
> >> So I did more testing on the 3.11 kernel and while it works OK with
> >> tar you can get severe lockups with mc or kvm. The difference is
> >> probably the fact that sane tools do fsync() on files they close
> >> forcing the file to write out and the kernel returning possible write
> >> errors before they move on to next file.
> >   Sorry for chiming in a bit late. But is this really writing to a normal
> > disk? SATA drive or something else?
> >
> >> With kvm writing to a file used as virtual disk the system would stall
> >> indefinitely until the disk driver in the emulated system would time
> >> out, return disk IO error, and the emulated system would stop writing.
> >> In top I see all CPU cores 90%+ in wait. System is unusable. With mc
> >> the lockups would be indefinite, probably because there is no timeout
> >> on writing a file in mc.
> >>
> >> I tried tuning swappiness and eleveators but the the basic problem is
> >> solved by neither: the dirty buffers fill up memory and system stalls
> >> trying to resolve the situation.
> >   This is really strange. There is /proc/sys/vm/dirty_ratio, which limits
> > amount of dirty memory. By default it is set to 20% of memory which tends
> > to be too much for 8 GB machine. Can you set it to something like 5% and
> > /proc/sys/vm/dirty_background_ratio to 2%? That would be more appropriate
> > sizing (assuming standard SATA drive). Does it change anything?
> 
> The default for dirty_ratio/dirty_background_ratio is 60/40. Setting
  Ah, that's not upstream default. Upstream has 20/10. In SLES we use 40/10
to better accomodate some workloads but 60/40 on 8 GB machines with
SATA drive really seems too much. That is going to give memory management a
headache.

The problem is that a good SATA drive can do ~100 MB/s if we are
lucky and IO is sequential. Thus if you have 5 GB of dirty data to write,
it takes 50s at best to write it, with more random IO to image file it can
well take several minutes to write. That may cause some increased latency
when memory reclaim waits for writeback to clean some pages.

> these to 5/2 gives about the same result as running the script that
> syncs every 5s. Setting to 30/10 gives larger data chunks and
> intermittent lockup before every chunk is written.
> 
> It is quite possible to set kernel parameters that kill the kernel but
> 
> 1) this is the default
  Not upstream one so you should raise this with Debian I guess. 60/40
looks way out of reasonable range for todays machines.

> 2) the parameter is set in units that do not prevent the issue in
> general (% RAM vs #blocks)
  You can set the number of bytes instead of percentage -
/proc/sys/vm/dirty_bytes / dirty_background_bytes. It's just that proper
sizing depends on amount of memory, storage HW, workload. So it's more an
administrative task to set this tunable properly.

> 3) WTH is the system doing? It's 4core 3GHz cpu so it can handle
> traversing a structure holding 800M data in the background. Something
> is seriously rotten somewhere.
  Likely processes are waiting in direct reclaim for IO to finish. But that
is just guessing. Try running attached script (forgot to attach it to
previous email). You will need systemtap and kernel debuginfo installed.
The script doesn't work with all versions of systemtap (as it is sadly a
moving target) so if it fails, tell me your version of systemtap and I'll
update the script accordingly.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--45Z9DzgjV8m4Oswq
Content-Type: application/x-perl
Content-Disposition: attachment; filename="watch-dstate.pl"
Content-Transfer-Encoding: quoted-printable

#!/usr/bin/perl=0A# This script is a combined perl and systemtap script to =
collect information=0A# on a system stalling in writeback. Ordinarily, one =
would expect that all=0A# information be collected in a STAP script. Unfort=
unately, in practice the=0A# stack unwinder in systemtap may not work with =
a current kernel version,=0A# have trouble collecting all the data necessar=
y or some other oddities.=0A# Hence this hack. A systemtap script is run an=
d as it records interesting=0A# events, the remaining information is collec=
ted from the script. This means=0A# that the data is *never* exact but can =
be better than nothing and easier=0A# than a fully manual check=0A#=0A# Cop=
yright Mel Gorman <mgorman@suse.de> 2011=0A=0Ause File::Temp qw/mkstemp/;=
=0Ause File::Find;=0Ause FindBin qw($Bin);=0Ause Getopt::Long;=0Ause strict=
;=0A=0Amy @trace_functions =3D (=0A	# "get_request_wait" is now special cas=
ed unfortunately=0A	"wait_for_completion",=0A	"wait_on_page_bit",=0A	"wait_=
on_page_bit_killable",=0A	"try_to_free_pages",=0A	"shrink_zone");=0A=0Amy @=
trace_conditional =3D (=0A	"sync_page",=0A	"sync_buffer",=0A	"sleep_on_buff=
er",=0A	"try_to_compact_pages",=0A	"balance_dirty_pages_ratelimited_nr",=0A=
	"balance_dirty_pages",=0A	"jbd2_log_wait_commit",=0A	"__jbd2_log_wait_for_=
space",=0A	"log_wait_commit",=0A	"__log_wait_for_space");=0A=0A# Informatio=
n on each stall is gathered and stored in a hash table for=0A# dumping late=
r. Define some constants for the table lookup to avoid=0A# blinding headach=
es=0Ause constant VMSTAT_AT_STALL       =3D> 0;=0Ause constant VMSTAT_AT_CO=
MPLETE    =3D> 1;=0Ause constant BLOCKSTAT_AT_STALL    =3D> 2;=0Ause consta=
nt BLOCKSTAT_AT_COMPLETE =3D> 3;=0Ause constant PROCNAME              =3D> =
4;=0Ause constant STACKTRACE            =3D> 5;=0Ause constant STALLFUNCTIO=
N         =3D> 6;=0A=0Ause constant NR_WRITEBACK =3D> 0;=0Ause constant NR_=
DIRTY     =3D> 2;=0Ause constant VMSCAN_WRITE =3D> 1;=0A=0Asub usage() {=0A=
	print("In general, this script is not supported and that includes help.\n"=
);=0A	exit(0);=0A}=0A=0A# Option variables=0Amy $opt_help;=0Amy $opt_output=
;=0Amy $opt_traceout;=0AGetOptions(=0A	'help|h'		=3D> \$opt_help,=0A	'outpu=
t|o=3Ds'		=3D> \$opt_output,=0A	'traceout|t=3Ds'		=3D> \$opt_traceout,=0A);=
=0A=0Ausage() if $opt_help;=0Aif ($opt_output) {=0A	open(OUTPUT, ">$opt_out=
put") || die("Failed to open $opt_output for writing");=0A}=0Aif ($opt_trac=
eout) {=0A	open(TRACEOUT, ">$opt_traceout") || die("Failed to open $opt_tra=
ceout for writing");=0A}=0A=0Amy @symbols;=0Amy @addresses;=0A=0A# Handle c=
leanup of temp files=0Amy $stappid;=0Amy ($handle, $stapscript) =3D mkstemp=
("/tmp/stapdXXXXX");=0Asub cleanup {=0A	if (defined($stappid)) {=0A		kill I=
NT =3D> $stappid;=0A	}=0A	if (defined($opt_output)) {=0A		close(OUTPUT);=0A=
	}=0A	unlink($stapscript);=0A}=0Asub sigint_handler {=0A	close(STAP);=0A	cl=
eanup();=0A	exit(0);=0A}=0A$SIG{INT} =3D "sigint_handler";=0A=0A# Build a l=
ist of stat files to read. Obviously this is not great if device=0A# hotplu=
g occurs but that is not expected for the moment and this is lighter=0A# th=
an running find every time=0Amy @block_iostat_files;=0Asub d {=0A	my $file =
=3D $File::Find::name;=0A	return if $file eq "/sys/block";=0A	push(@block_i=
ostat_files, "$file/stat");=0A}=0Afind(\&d, ("/sys/block/"));=0A=0Asub bins=
earch {=0A	my $val =3D $_[0];=0A	my $arr =3D $_[1];=0A	my $s =3D 0;=0A	my $=
e =3D $#{$arr};=0A	my $m;=0A=0A	while ($s < $e) {=0A		$m =3D ($s + $e + 1) =
/ 2;=0A		if (${$arr}[$m] < $val) {=0A			$s =3D $m;=0A		} elsif (${$arr}[$m]=
 > $val) {=0A			$e =3D $m - 1;=0A		} else {=0A			return $m;=0A		}=0A	}=0A	r=
eturn $e;=0A}=0A=0A##=0A# Read the stack trace from the trace buffer=0Asub =
read_stacktrace {=0A	my $stack;=0A	my $index;=0A	my $addr;=0A	my @line;=0A	=
my $fh =3D shift;=0A=0A	while (<$fh>) {=0A		log_trace($_);=0A		chomp;=0A		@=
line =3D split/ +/;=0A		if ($line[5] eq "--") {=0A			last;=0A		}=0A		$addr =
=3D hex($line[5]);=0A		$index =3D binsearch($addr, \@addresses);=0A		if ($i=
ndex > 0) {=0A			$stack .=3D sprintf("<%016lx> %s\n",=0A					  $addr, $symb=
ols[$index]);=0A		}=0A	}=0A	return $stack;=0A}=0A=0A##=0A# Read information=
 of relevant from /proc/vmstat=0Asub read_vmstat {=0A	if (!open(VMSTAT, "/p=
roc/vmstat")) {=0A		cleanup();=0A		die("Failed to read /proc/vmstat");=0A	}=
=0A=0A	my $vmstat;=0A	my ($key, $value);=0A	my @values;=0A	while (!eof(VMST=
AT)) {=0A		$vmstat =3D <VMSTAT>;=0A		($key, $value) =3D split(/\s+/, $vmsta=
t);=0A		chomp($value);=0A=0A		if ($key eq "nr_writeback") {=0A			$values[NR=
_WRITEBACK] =3D $value;=0A		}=0A		if ($key eq "nr_dirty") {=0A			$values[NR=
_DIRTY] =3D $value;=0A		}=0A		if ($key eq "nr_vmscan_write") {=0A			$values=
[VMSCAN_WRITE] =3D $value;=0A		}=0A	}=0A=0A	return \@values;=0A}=0A=0A##=0A=
# Read information from all /sys/block stat files=0Asub read_blockstat($) {=
=0A	my $prefix =3D $_[0];=0A	my $stat;=0A	my $ret;=0A	=0A	foreach $stat (@b=
lock_iostat_files) {=0A		if (open(STAT, $stat)) {=0A			$ret .=3D sprintf "%=
s%20s %s", $prefix, $stat, <STAT>;=0A			close(STAT);=0A		}=0A	}=0A	return $=
ret;=0A}=0A=0A##=0A# Record a line of output=0Asub log_printf {=0A	if (defi=
ned($opt_output)) {=0A		printf OUTPUT @_;=0A	}=0A	printf @_;=0A}=0A=0Asub l=
og_trace {=0A	if (defined($opt_traceout)) {=0A		print TRACEOUT @_;=0A	}=0A}=
=0A=0A# Read kernel symbols and add conditional trace functions if they exi=
st=0Aopen(KALLSYMS, "/proc/kallsyms") || die("Failed to open /proc/kallsyms=
");=0Amy $found_get_request_wait =3D 0;=0Awhile (<KALLSYMS>) {=0A	my ($addr=
, $type, $symbol) =3D split(/\s+/, $_);=0A	my $conditional;=0A=0A	push(@sym=
bols, $symbol);=0A	push(@addresses, hex($addr));=0A	if ($symbol eq "get_req=
uest_wait") {=0A		push(@trace_functions, $symbol);=0A		$found_get_request_w=
ait =3D 1;=0A		next;=0A	}=0A	foreach $conditional (@trace_conditional) {=0A=
		if ($symbol eq $conditional) {=0A			push(@trace_functions, $symbol);=0A		=
	last;=0A		}=0A	}=0A}=0Aclose(KALLSYMS);=0A=0Aif (!$found_get_request_wait)=
 {=0A	push(@trace_functions, "get_request");=0A}=0A=0A# Extract the framewo=
rk script and fill in the rest=0Aopen(SELF, "$0") || die("Failed to open ru=
nning script");=0Awhile (<SELF>) {=0A	chomp($_);=0A	if ($_ ne "__END__") {=
=0A		next;=0A	}=0A	while (<SELF>) {=0A		print $handle $_;=0A	}=0A}=0Aforeac=
h(@trace_functions) {=0A	print $handle "probe kprobe.function(\"$_\")=0A{ =
=0A	t=3Dtid()=0A	stalled_at[t]=3Dtime()=0A	name[t]=3Dexecname()=0A	where[t]=
=3D\"$_\"=0A	delete stalled[t]=0A}";=0A}=0A=0Aforeach(@trace_functions) {=
=0A	print $handle "probe kprobe.function(\"$_\").return=0A{=0A	t=3Dtid()=0A=
=0A	if ([t] in stalled) %{ {=0A		char *where =3D _stp_map_get_is(global.s_w=
here, l->t);=0A		int i;=0A		unsigned long stack_entries[MAX_STACK_ENTRIES];=
=0A		struct stack_trace trace =3D {=0A			.skip =3D 6,=0A			.max_entries =3D=
 MAX_STACK_ENTRIES,=0A			.entries =3D stack_entries=0A		};=0A=0A		trace_pri=
ntk(\"C %s\\n\", where ? : \"\");=0A		save_stack_trace(&trace);=0A		for (i =
=3D 0; i < trace.nr_entries; i++)=0A			if (stack_entries[i] !=3D ULONG_MAX)=
=0A				trace_printk(\"%lx\\n\", stack_entries[i]);=0A		trace_printk(\"--\\n=
\");=0A		0;=0A	} %}=0A=0A	delete stalled[t]=0A	delete stalled_at[t]=0A	dele=
te name[t]=0A	delete where[t]=0A}"=0A}=0A=0Aclose($handle);=0A=0A# Contact=
=0A$stappid =3D open(STAP, "stap -g $stapscript|");=0Aif (!defined($stappid=
)) {=0A	die("Failed to execute stap script");=0A}=0A=0Aopen(TRACE, "<", "/s=
ys/kernel/debug/tracing/trace_pipe") || die("Cannot open trace pipe!");=0A=
=0A# Collect information until interrupted=0Amy %stalled;=0Awhile (1) {=0A	=
my $input =3D <TRACE>;=0A	log_trace($input);=0A        #              proc-=
pid CPU        state? time              func   data...=0A	if ($input =3D~ /=
 +[^ ]+ +\[[0-9]*\].* ([0-9]+\.[0-9]+): probe_[0-9]+: S ([0-9]*) \((.*)\) (=
[0-9]*) ms (.*)/) {=0A		my $pid      =3D $2;=0A		my $name     =3D $3;=0A		m=
y $stallbegin =3D $1*1000 - $4;=0A		my $where    =3D $5;=0A	=0A		if (define=
d($stalled{$pid}->{NAME})) {=0A			cleanup();=0A			print("Apparently recursi=
ng stalls! This should not happen.\n");=0A			print("Process:  $pid ($name)\=
n");=0A			print("Stalled:  " . $stalled{$pid}->{STALLFUNCTION} . "\n");=0A	=
		print($stalled{$pid}->{STACKTRACE});=0A			print("Stalling: $where\n");=0A=
			exit(-1);=0A		}=0A		$stalled{$pid}->{NAME} =3D $name;=0A		$stalled{$pid}=
->{VMSTAT_AT_STALL} =3D read_vmstat();=0A		$stalled{$pid}->{BLOCKSTAT_AT_ST=
ALL} =3D read_blockstat("-");=0A		$stalled{$pid}->{STALLFUNCTION} =3D $wher=
e;=0A		$stalled{$pid}->{STALLBEGIN} =3D $stallbegin;=0A	} elsif ($input =3D=
~ / +[^ ]+-([0-9]+) +\[[0-9]*\].* ([0-9]+\.[0-9]+): probe_[0-9]+: C (.*)/) =
{=0A		my $pid      =3D $1;=0A		my $stallend =3D $2*1000;=0A		my $where    =
=3D $3;=0A=0A		if ($where ne $stalled{$pid}->{STALLFUNCTION}) {=0A			cleanu=
p();=0A			die("The stalling function teleported.");=0A		}=0A=0A		$stalled{$=
pid}->{STACKTRACE} =3D read_stacktrace(\*TRACE);=0A		$stalled{$pid}->{VMSTA=
T_AT_COMPLETE} =3D read_vmstat();=0A		$stalled{$pid}->{BLOCKSTAT_AT_COMPLET=
E} =3D read_blockstat("+");=0A		my $delta_writeback    =3D $stalled{$pid}->=
{VMSTAT_AT_COMPLETE}[NR_WRITEBACK] - $stalled{$pid}->{VMSTAT_AT_STALL}[NR_W=
RITEBACK];=0A		my $delta_dirty        =3D $stalled{$pid}->{VMSTAT_AT_COMPLE=
TE}[NR_DIRTY]     - $stalled{$pid}->{VMSTAT_AT_STALL}[NR_DIRTY];=0A		my $de=
lta_vmscan_write =3D $stalled{$pid}->{VMSTAT_AT_COMPLETE}[VMSCAN_WRITE] - $=
stalled{$pid}->{VMSTAT_AT_STALL}[VMSCAN_WRITE];=0A=0A		# Blind stab in the =
dark as to what is going on=0A		my $status;=0A		if ($where eq "balance_dirt=
y_pages") {=0A			$status =3D "DirtyThrottled";=0A		} else {=0A			$status =
=3D "IO";=0A		}=0A		if ($delta_writeback < 0) {=0A			$status =3D "${status}=
_WritebackInProgress";=0A		}=0A		if ($delta_writeback > 0) {=0A			$status =
=3D "${status}_WritebackSlow";=0A		}=0A=0A		log_printf("time %d %u (%s) Sta=
lled: %u ms: %s\n", time(),=0A			   $pid, $stalled{$pid}->{NAME},=0A			   $=
stallend - $stalled{$pid}->{STALLBEGIN}, $where);=0A		log_printf("Guessing:=
 %s\n", $status);=0A		log_printf("-%-15s %12d\n", "nr_dirty",        $stall=
ed{$pid}->{VMSTAT_AT_STALL}[NR_DIRTY]);=0A		log_printf("-%-15s %12d\n", "nr=
_writeback",    $stalled{$pid}->{VMSTAT_AT_STALL}[NR_WRITEBACK]);=0A		log_p=
rintf("-%-15s %12d\n", "nr_vmscan_write", $stalled{$pid}->{VMSTAT_AT_STALL}=
[VMSCAN_WRITE]);=0A		log_printf("%s", $stalled{$pid}->{BLOCKSTAT_AT_STALL})=
;=0A		log_printf("+%-15s %12d %12d\n", "nr_dirty",=0A			$stalled{$pid}->{VM=
STAT_AT_COMPLETE}[NR_DIRTY], $delta_dirty);=0A		log_printf("+%-15s %12d %12=
d\n", "nr_writeback",=0A			$stalled{$pid}->{VMSTAT_AT_COMPLETE}[NR_WRITEBAC=
K], $delta_writeback);=0A		log_printf("+%-15s %12d %12d\n", "nr_vmscan_writ=
e",=0A			$stalled{$pid}->{VMSTAT_AT_COMPLETE}[VMSCAN_WRITE],=0A			$delta_vm=
scan_write);=0A		log_printf("%s", $stalled{$pid}->{BLOCKSTAT_AT_COMPLETE});=
=0A		log_printf($stalled{$pid}->{STACKTRACE});=0A=0A		delete($stalled{$pid}=
);=0A	} else {=0A		cleanup();=0A		die("Failed to parse input from stap scri=
pt:\n".$input);=0A	}=0A}=0A=0Acleanup();=0Aexit(0);=0A__END__=0A%{=0A#inclu=
de <linux/kernel.h>=0A#include <linux/stacktrace.h>=0A=0A#define MAX_STACK_=
ENTRIES 32=0A%}=0A=0Afunction time () { return gettimeofday_ms() }=0Aglobal=
 stall_threshold =3D 1000=0Aglobal stalled_at, stalled, where=0Aglobal name=
=0A=0Aprobe timer.profile {=0A	foreach (tid+ in stalled_at) {=0A		if ([tid]=
 in stalled) continue=0A=0A		stall_time =3D time() - stalled_at[tid]=0A		if=
 (stall_time >=3D stall_threshold) {=0A			%{ {=0A			char *where =3D _stp_ma=
p_get_is(global.s_where, l->tid);=0A			char *pname =3D _stp_map_get_is(glob=
al.s_name, l->tid);=0A=0A			trace_printk("S %lld (%s) %lld ms %s\n", l->tid=
, pname ? : "", l->stall_time, where ? : "");=0A			0;=0A			} %}=0A			stalle=
d[tid] =3D 1 # defer further reports to wakeup=0A		}=0A	}=0A}=0A=0A
--45Z9DzgjV8m4Oswq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
