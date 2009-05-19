Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C54956B005D
	for <linux-mm@kvack.org>; Tue, 19 May 2009 01:10:57 -0400 (EDT)
Date: Tue, 19 May 2009 13:09:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090519050932.GB8769@localhost>
References: <alpine.DEB.1.10.0905181045340.20244@qirst.com> <20090519032759.GA7608@localhost> <20090519133422.4ECC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="rwEMma7ioTxnRzrJ"
Content-Disposition: inline
In-Reply-To: <20090519133422.4ECC.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, May 19, 2009 at 12:41:38PM +0800, KOSAKI Motohiro wrote:
> Hi
> 
> Thanks for great works.
> 
> 
> > SUMMARY
> > =======
> > The patch decreases the number of major faults from 50 to 3 during 10% cache hot reads.
> > 
> > 
> > SCENARIO
> > ========
> > The test scenario is to do 100000 pread(size=110 pages, offset=(i*100) pages),
> > where 10% of the pages will be activated:
> > 
> >         for i in `seq 0 100 10000000`; do echo $i 110;  done > pattern-hot-10
> >         iotrace.rb --load pattern-hot-10 --play /b/sparse
> 
> 
> Which can I download iotrace.rb?

In the attachment. It relies on some ruby libraries.

> > and monitor /proc/vmstat during the time. The test box has 2G memory.
> > 
> > 
> > ANALYZES
> > ========
> > 
> > I carried out two runs on fresh booted console mode 2.6.29 with the VM_EXEC
> > patch, and fetched the vmstat numbers on
> > 
> > (1) begin:   shortly after the big read IO starts;
> > (2) end:     just before the big read IO stops;
> > (3) restore: the big read IO stops and the zsh working set restored
> > 
> >         nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
> > begin:       2481             2237             8694              630                0           574299
> > end:          275           231976           233914              633           776271         20933042
> > restore:      370           232154           234524              691           777183         20958453
> > 
> > begin:       2434             2237             8493              629                0           574195
> > end:          284           231970           233536              632           771918         20896129
> > restore:      399           232218           234789              690           774526         20957909
> > 
> > and another run on 2.6.30-rc4-mm with the VM_EXEC logic disabled:
> 
> I don't think it is proper comparision.
> you need either following comparision. otherwise we insert many guess into the analysis.
> 
>  - 2.6.29 with and without VM_EXEC patch
>  - 2.6.30-rc4-mm with and without VM_EXEC patch

I think it doesn't matter that much when it comes to "relative" numbers.
But anyway I guess you want to try a more typical desktop ;)
Unfortunately currently the Xorg is broken in my test box..

> > 
> > begin:       2479             2344             9659              210                0           579643
> > end:          284           232010           234142              260           772776         20917184
> > restore:      379           232159           234371              301           774888         20967849
> > 
> > The numbers show that
> > 
> > - The startup pgmajfault of 2.6.30-rc4-mm is merely 1/3 that of 2.6.29.
> >   I'd attribute that improvement to the mmap readahead improvements :-)
> > 
> > - The pgmajfault increment during the file copy is 633-630=3 vs 260-210=50.
> >   That's a huge improvement - which means with the VM_EXEC protection logic,
> >   active mmap pages is pretty safe even under partially cache hot streaming IO.
> > 
> > - when active:inactive file lru size reaches 1:1, their scan rates is 1:20.8
> >   under 10% cache hot IO. (computed with formula Dpgdeactivate:Dpgfree)
> >   That roughly means the active mmap pages get 20.8 more chances to get
> >   re-referenced to stay in memory.
> > 
> > - The absolute nr_mapped drops considerably to 1/9 during the big IO, and the
> >   dropped pages are mostly inactive ones. The patch has almost no impact in
> >   this aspect, that means it won't unnecessarily increase memory pressure.
> >   (In contrast, your 20% mmap protection ratio will keep them all, and
> >   therefore eliminate the extra 41 major faults to restore working set
> >   of zsh etc.)
> 
> I'm surprised this.
> Why your patch don't protect mapped page from streaming io?

It is only protecting the *active* mapped pages, as expected.
But yes, the active percent is much lower than expected :-)

> I strongly hope reproduce myself, please teach me reproduce way.

OK. 

Firstly:

         for i in `seq 0 100 10000000`; do echo $i 110;  done > pattern-hot-10
         dd if=/dev/zero of=/tmp/sparse bs=1M count=1 seek=1024000

Then boot into desktop and run concurrently:

         iotrace.rb --load pattern-hot-10 --play /tmp/sparse
         vmmon  nr_mapped nr_active_file nr_inactive_file   pgmajfault pgdeactivate pgfree

Note that I was creating the sparse file in btrfs, which happens to be
very slow in sparse file reading:

        151.194384MB/s 284.198252s 100001x 450560b --load pattern-hot-10 --play /b/sparse

In that case, the inactive list is rotated at the speed of 250MB/s,
so a full scan of which takes about 3.5 seconds, while a full scan
of active file list takes about 77 seconds.

Attached source code for both of the above tools.

Thanks,
Fengguang

--rwEMma7ioTxnRzrJ
Content-Type: application/x-ruby
Content-Disposition: attachment; filename="iotrace.rb"
Content-Transfer-Encoding: quoted-printable

#!/usr/bin/ruby=0A#=0A# 1) generate I/O patterns=0A# 2) play I/O traces=0A#=
=0A# 2006, 2007	Fengguang Wu=0A=0APLAYIO_VERSION=3D'0.1'=0A=0Arequire 'optp=
arse'=0Arequire 'ostruct'=0Arequire 'mmap'=0A=0ACMDLINE =3D ARGV.join ' '=
=0A=0APAGE_SHIFT =3D 12=0APAGE_SIZE =3D 1 << PAGE_SHIFT=0AUNITS =3D {?g =3D=
> 30, ?m =3D> 20, ?p =3D> PAGE_SHIFT, ?k =3D> 10, ?b =3D> 0 }=0A$base_shift=
 =3D PAGE_SHIFT=0A=0A$options =3D OpenStruct.new=0A$options.unit =3D ?p=0A$=
options.align_mask =3D 0xffffffffff=0A$options.pos_bounds =3D [0, 10 << 20]=
		# min, max=0A$options.len_bounds =3D [PAGE_SIZE, PAGE_SIZE]=0A$options.sk=
ip_bounds =3D [0, 0]=0A$options.max_bytes =3D 1 << 48=0A$options.max_time =
=3D 1000=0A$options.max_requests =3D 1 << 48=0A$options.pattern =3D 'sequen=
tial'=0A$options.think_time =3D 0=0A$options.pdf =3D 'uniform'=0A=0A$pages =
=3D Hash.new=0A=0Adef s2i(s)=0A	i =3D s.to_i=0A	shift =3D UNITS[s[-1]] || U=
NITS[$options.unit]=0A	$base_shift =3D shift if $base_shift > shift=0A	i <<=
=3D shift=0A	i=0Aend=0A=0Adef i2s(i)=0A	UNITS.each do |suffix, shift|=0A		i=
f i & ((1 << shift) - 1) =3D=3D 0 and $base_shift >=3D shift=0A			return (i=
 >> shift).to_s + suffix.chr=0A		end=0A	end=0A	i.to_s=0Aend=0A=0Aclass IOTr=
ace=0A=0A	def initialize=0A		@io =3D Array.new=0A	end=0A=0A	def io=0A		@io=
=0A	end=0A=0A	def create=0A		srand Time::now.usec=0A		pat_first =3D self.me=
thod("#{$options.pattern}_first")=0A		pat_next  =3D self.method("#{$options=
=2Epattern}_next")=0A		bytes =3D 0=0A		request =3D pat_first.call=0A		loop =
do=0A			bytes +=3D request[1]=0A			@io << request=0A			break if bytes >=3D =
$options.max_bytes=0A			break if @io.size >=3D $options.max_requests=0A			r=
equest =3D pat_next.call=0A			break if request =3D=3D nil=0A		end=0A	end=0A=
=0A	def load(file)=0A		File.open(file).each_line do |line|=0A			pos, len =
=3D line.split=0A			next if pos[0] =3D=3D ?#=0A			len ||=3D '1p'=0A			@io <=
< [s2i(pos), s2i(len)]=0A		end=0A	end=0A=0A	def save(file)=0A		File.open(fi=
le, 'w') do |f|=0A			f.puts "# iotrace.rb #{CMDLINE}"=0A			@io.each do |r|=
=0A				pos, len =3D r=0A				f.print i2s(pos)=0A				f.print "\t", i2s(len) i=
f len !=3D (1 << $base_shift)=0A				f.print "\n"=0A			end=0A		end=0A	end=0A=
=0A	def play(bdev)=0A		system("fadvise #{bdev} 0 0 dontneed")=0A		ppos =3D =
-1=0A		File.open(bdev) do |f|=0A			seeks =3D 0=0A			bytes =3D 0=0A			start =
=3D Time.now=0A			@io.each do |r|=0A				pos, len =3D r=0A				if pos !=3D pp=
os=0A					f.sysseek(pos)=0A					seeks +=3D 1=0A				end=0A				f.sysread(len)=
=0A				ppos =3D pos + len=0A				bytes +=3D len=0A				break if bytes >=3D $o=
ptions.max_bytes=0A				break if Time.now - start >=3D $options.max_time=0A	=
			sleep 0.001 * $options.think_time=0A			end=0A			stop =3D Time.now=0A			t=
hroughput =3D bytes / (stop - start)=0A			runlen =3D bytes / seeks=0A			pri=
ntf "%fMB/s %fs %dx %db %s\n", throughput/(1<<20), stop - start, seeks, run=
len, CMDLINE=0A		end=0A	end=0A=0A	def mplay(bdev)=0A		system("fadvise #{bde=
v} 0 0 dontneed")=0A		mmap_file =3D Mmap.new(bdev,=0A				     mode =3D "r",=
=0A				     protection =3D Mmap::MAP_SHARED,=0A				     options =3D {})=0A	=
	# 'length' =3D> 1*1024*1024*1024=0A		# 'advice' =3D> Mmap::MADV_NORMAL, Mm=
ap::MADV_RANDOM, Mmap::MADV_SEQUENTIAL, Mmap::MADV_WILLNEED, Mmap::MADV_DON=
TNEED=0A		data =3D 0=0A		bytes =3D 0=0A		@io.each do |r|=0A			pos, len =3D =
r=0A			mmap_file[pos, len]=0A			bytes +=3D len=0A			break if bytes >=3D $op=
tions.max_bytes=0A			# pgoff =3D -1=0A			# pos.upto(pos+len) { |offset|=0A	=
			# next if pgoff =3D=3D offset / 4096=0A				# pgoff =3D offset / 4096=0A	=
			# data =3D data | mmap_file[offset]=0A			# }=0A			sleep 0.001 * $options=
=2Ethink_time=0A		end=0A	end=0A=0A	def break_up(file)=0A		bio =3D Array.new=
=0A		time =3D 1=0A		File.open(file, 'w') do |f|=0A			f.puts "# playio.rb #{=
CMDLINE}"=0A			@io.each do |r|=0A				pos, len =3D r=0A				loop do=0A					l =
=3D (len < alen ? len : alen)=0A					bio << [pos, l]=0A					f.print time=0A=
					f.print "\t", i2s(pos)=0A					f.print "\t", i2s(l) if l !=3D (1 << $ba=
se_shift)=0A					f.print "\n"=0A					len -=3D l=0A					break if len <=3D 0=
=0A					pos +=3D l=0A				end=0A				time =3D time + 1=0A			end=0A		end=0A		@=
io =3D bio=0A	end=0A=0A	def round_up=0A		@io.each_index do |i|=0A			pos, le=
n =3D @io[i]=0A			epos =3D (pos + len + ~$options.align_mask) & $options.al=
ign_mask=0A			pos &=3D $options.align_mask=0A			@io[i] =3D [pos, epos - pos=
 ]=0A		end=0A	end=0A=0A	def shuffle(count, scope)=0A		i =3D rand(scope)=0A	=
	count.times do=0A			j =3D (i + rand(scope)) % (@io.size)=0A			tmp =3D @io[=
i]=0A			@io[i] =3D @io[j]=0A			@io[j] =3D tmp=0A			i =3D j=0A		end=0A	end=
=0A=0A	def interleave(b)=0A		aio =3D Array.new=0A		i =3D 0=0A		j =3D 0=0A		=
n =3D @io.size + b.io.size=0A		loop do=0A			r =3D rand(n)=0A			if r < @io.s=
ize and i < @io.size=0A				aio << @io[i]=0A				i +=3D 1=0A			elsif j < b.io=
=2Esize=0A				aio << b.io[j]=0A				j +=3D 1=0A			elsif i < @io.size=0A				a=
io << @io[i]=0A				i +=3D 1=0A			else=0A				break=0A			end=0A		end=0A		@io =
=3D aio=0A	end=0A=0A	def arand(bounds)=0A		n =3D bounds[0]=0A		len =3D boun=
ds[1] - bounds[0] + 1=0A		if $options.pdf =3D=3D 'uniform'=0A			n +=3D rand=
(len)=0A		elsif $options.pdf =3D=3D 'clustered'=0A			n =3D len * (0.5 + (0.=
5 - rand()) * rand()).to_i=0A		end=0A		n &=3D $options.align_mask=0A	end=0A=
	def apos=0A		arand $options.pos_bounds=0A	end=0A	def alen=0A		arand $optio=
ns.len_bounds=0A	end=0A	def askip=0A		arand $options.skip_bounds=0A	end=0A=
=0A	def random_first=0A		[apos, alen]=0A	end=0A	alias random_next random_fi=
rst=0A=0A	# out-of-order: (non-overlapping) non-repeating random=0A	def ooo=
_first=0A		pos =3D 0=0A		loop do=0A			pos =3D apos=0A			if not $pages[pos]=
=0A				$pages[pos] =3D 1=0A				break=0A			end=0A		end=0A		[pos, alen]=0A	en=
d=0A	alias ooo_next ooo_first=0A=0A	def sequential_first=0A		[$options.pos_=
bounds[0], alen]=0A	end=0A=0A	def sequential_next=0A		pos =3D @io.last[0] +=
 @io.last[1] + askip=0A		[pos, alen] if pos < $options.pos_bounds[1]=0A	end=
=0A=0A	def backward_first=0A		[$options.pos_bounds[1], alen]=0A	end=0A=0A	d=
ef backward_next=0A		len =3D alen=0A		pos =3D @io.last[0] - len - askip=0A	=
	[pos, len] if pos >=3D $options.pos_bounds[0]=0A	end=0A=0Aend=0A=0Aiotrace=
 =3D IOTrace.new=0A=0A=0Aopts =3D OptionParser.new do |opts|=0A	opts.banner=
 =3D "Usage: playio.rb [$options]"=0A=0A	opts.separator ""=0A	opts.separato=
r "Parameters:"=0A=0A	opts.on("--unit p|b|k|m|g", "set default size unit: P=
age/Byte/Kilo/Mega/Giga") do |u|=0A		$options.unit =3D u[0]=0A	end=0A=0A	op=
ts.on("--max-requests REQUESTS", "define total I/O requests limit") do |n|=
=0A		$options.max_requests =3D n=0A	end=0A=0A	opts.on("--max-bytes BYTES", =
"define total I/O bytes limit") do |n|=0A		$options.max_bytes =3D s2i(n)=0A=
	end=0A=0A	opts.on("--max-seconds SECONDS", "define total I/O time limit") =
do |n|=0A		$options.max_time =3D n.to_f=0A	end=0A=0A	opts.on("--offset [BEG=
IN=3D0,]END", "define I/O offset range") do |list|=0A		a, b =3D list.split =
','=0A		if b =3D=3D nil=0A			b =3D a=0A			a =3D 0=0A		end=0A		a =3D s2i(a)=
=0A		b =3D s2i(b)=0A		$options.pos_bounds =3D [a, b]=0A	end=0A=0A	opts.on("=
--size MIN[,MAX=3DMIN]", "define I/O size range") do |list|=0A		a, b =3D li=
st.split ','=0A		b ||=3D a=0A		a =3D s2i(a)=0A		b =3D s2i(b)=0A		$options.l=
en_bounds =3D [a, b]=0A	end=0A=0A	opts.on("--skip MIN[,MAX=3DMIN]", "define=
 I/O skip range") do |list|=0A		a, b =3D list.split ','=0A		b ||=3D a=0A		a=
 =3D s2i(a)=0A		b =3D s2i(b)=0A		$options.skip_bounds =3D [a, b]=0A	end=0A=
=0A	opts.on("--align BOUNDARY", "align I/O offset/size to BOUNDARY") do |n|=
=0A		$options.align_mask =3D ~(s2i(n) - 1)=0A	end=0A=0A	opts.on("--pattern =
PATTERN", "define I/O pattern") do |pat|=0A		$options.pattern =3D pat=0A	en=
d=0A=0A	opts.on("--pdf DISTRIBUTION", "define random pattern") do |pdf|=0A	=
	$options.pdf =3D pdf=0A	end=0A=0A	opts.on("--think-time MSEC", "define thi=
nk time between I/O requests") do |t|=0A		$options.think_time =3D t.to_f=0A=
	end=0A=0A	opts.separator ""=0A	opts.separator "Actions:"=0A=0A	opts.on("-c=
", "--create", "create I/O trace") do |file|=0A		iotrace.create=0A	end=0A=
=0A	opts.on("-b", "--break-up [FILE]", "break up to new size and save time-=
offset-size") do |file|=0A		iotrace.break_up file || '/dev/null'=0A	end=0A=
=0A	opts.on("-r", "--round-up", "round up to new align") do=0A		iotrace.rou=
nd_up=0A	end=0A=0A	opts.on("-x", "--shuffle [N,M]", "shuffle N times with l=
ocality M") do |list|=0A		n, m =3D list.split ','=0A		iotrace.shuffle((n.to=
_i || iotrace.io.size), (m.to_i || iotrace.io.size))=0A	end=0A=0A	opts.on("=
-l", "--load FILE", "load I/O trace from FILE") do |file|=0A		iotrace.load =
file=0A	end=0A=0A	opts.on("-i", "--interleave FILE", "interleave I/O with F=
ILE") do |file|=0A		b =3D IOTrace.new=0A		b.load file=0A		iotrace.interleav=
e b=0A	end=0A=0A	opts.on("-s", "--save FILE", "save I/O trace to FILE") do =
|file|=0A		iotrace.save file=0A	end=0A=0A	opts.on("-p", "--play [FILE]", "p=
lay I/O trace on FILE") do |file|=0A		iotrace.play file || '/tmp/sparse/100=
G'=0A	end=0A=0A	opts.on("--mplay [FILE]", "play I/O trace on FILE") do |fil=
e|=0A		iotrace.mplay file || '/tmp/sparse/100G'=0A	end=0A=0A	opts.on("--sle=
ep SEC", "sleep SEC seconds") do |sec|=0A		sleep sec.to_i=0A	end=0A=0A	opts=
=2Eseparator ""=0A	opts.separator "Others:"=0A      =0A	opts.on_tail("--pid=
 FILE", "Save pid to FILE") do |file|=0A		File.open(file, 'w') do |f|=0A			=
f.puts Process.pid=0A		end=0A	end=0A=0A	opts.on_tail("-h", "--help", "Show =
this message") do=0A		puts opts=0A		exit=0A	end=0A=0A	opts.on_tail("-v", "-=
-version", "Show version") do=0A		puts PLAYIO_VERSION=0A		exit=0A	end=0A=0A=
end=0A=0Aopts.parse!(ARGV)=0A=0A=0A# random=0A# ruby -e 'File.open("iotrace=
", "w") { |f| 100000.downto(1) { f.puts rand(1000000) } }'=0A#=0A# backward=
=0A# seq 10000 -1 0 > iotrace=0A#=0A# clear=0A# fadvise sparse 0 1000000000=
0 dontneed=0A
--rwEMma7ioTxnRzrJ
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="vmmon.c"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/time.h>

static int raw   = 1;
static int delay = 1;
static int nr_fields;
static char **fields;
static FILE *f;

static void acquire(long *values)
{
	char buf[1024];

	rewind(f);
	memset(values, 0, nr_fields * sizeof(*values));
	while (fgets(buf, sizeof(buf), f)) {
		int i;

		for (i = 0; i < nr_fields; i++) {
			char *p;

			if (strncmp(buf, fields[i], strlen(fields[i])))
				continue;
			p = strchr(buf, ' ');
			if (p == NULL) {
				fprintf(stderr, "vmmon: error parsing /proc\n");
				exit(1);
			}
			values[i] += strtoul(p, NULL, 10);
			break;
		}
	}
}

static void display(long *new_values, long *prev_values,
			unsigned long long usecs)
{
	int i;

	for (i = 0; i < nr_fields; i++) {
		if (raw)
			printf(" %16ld", new_values[i]);
		else {
			long long diff;
			double ddiff;
			ddiff = new_values[i] - prev_values[i];
			ddiff *= 1000000;
			ddiff /= usecs;
			diff = ddiff;
			printf(" %16lld", diff);
		}
	}
	printf("\n");
}

static void do1(long *prev_values)
{
	struct timeval start;
	struct timeval end;
	long long usecs;
	long new_values[nr_fields];

	gettimeofday(&start, NULL);
	sleep(delay);
	gettimeofday(&end, NULL);
	acquire(new_values);
	usecs = end.tv_sec - start.tv_sec;
	usecs *= 1000000;
	usecs += end.tv_usec - start.tv_usec;
	display(new_values, prev_values, usecs);
	memcpy(prev_values, new_values, nr_fields * sizeof(*prev_values));
}

static void heading(void)
{
	int i;

	printf("\n");
	for (i = 0; i < nr_fields; i++)
		printf(" %16s", fields[i]);
	printf("\n");
}

static void doit(void)
{
	int line = 0;
	long prev_values[nr_fields];

	acquire(prev_values);
	for ( ; ; ) {
		if (line == 0)
			heading();
		do1(prev_values);
		line++;
		if (line == 24)
			line = 0;
	}
}

static void usage(void)
{
	fprintf(stderr, "usage: vmmon [-r] [-d N] field [field ...]\n");
	fprintf(stderr, "   -d N             : delay N seconds\n");
	fprintf(stderr, "   -r               : show raw numbers instead of diff\n");
	exit(1);
}

int main(int argc, char *argv[])
{
	int c;

	while ((c = getopt(argc, argv, "rd:")) != -1) {
		switch (c) {
		case 'r':
			raw = 1;
		case 'd':
			delay = strtol(optarg, NULL, 10);
			break;
		default:
			usage();
		}
	}

	if (optind == argc)
		usage();

	nr_fields = argc - optind;
	fields = argv + optind;
	f = fopen("/proc/vmstat", "r");
	doit();
	exit(0);
}

--rwEMma7ioTxnRzrJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
