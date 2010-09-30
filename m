Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 297896B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 22:58:03 -0400 (EDT)
Date: Thu, 30 Sep 2010 10:57:50 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch]vmscan: protect exectuable page from inactive list scan
Message-ID: <20100930025750.GA10456@localhost>
References: <20100929101704.GB2618@cmpxchg.org>
 <1285805052.1773.9.camel@shli-laptop>
 <20100930112408.2A94.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Content-Disposition: inline
In-Reply-To: <20100930112408.2A94.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Li, Shaohua" <shaohua.li@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Sep 30, 2010 at 10:27:04AM +0800, KOSAKI Motohiro wrote:
> > On Wed, 2010-09-29 at 18:17 +0800, Johannes Weiner wrote:
> > > On Wed, Sep 29, 2010 at 10:57:40AM +0800, Shaohua Li wrote:
> > > > With commit 645747462435, pte referenced file page isn't activated in inactive
> > > > list scan. For VM_EXEC page, if it can't get a chance to active list, the
> > > > executable page protect loses its effect. We protect such page in inactive scan
> > > > here, now such page will be guaranteed cached in a full scan of active and
> > > > inactive list, which restores previous behavior.
> > > 
> > > This change was in the back of my head since the used-once detection
> > > was merged but there were never any regressions reported that would
> > > indicate a requirement for it.
> > The executable page protect is to improve responsibility. I would expect
> > it's hard for user to report such regression. 
> 
> Seems strange. 8cab4754d24a0f was introduced for fixing real world problem.
> So, I wonder why current people can't feel the same lag if it is.
> 
> 
> > > Does this patch fix a problem you observed?
> > No, I haven't done test where Fengguang does in commit 8cab4754d24a0f.
> 
> But, I am usually not against a number. If you will finished to test them I'm happy :)

Yeah, it needs good numbers for adding such special case code.
I attached the scripts used for 8cab4754d24a0f, hope this helps.

Note that the test-mmap-exec-prot.sh used /proc/sys/fs/suid_dumpable
as an indicator whether the extra logic is enabled. This is a convenient
trick I sometimes play with new code:

+                       extern int suid_dumpable;
+                       if (suid_dumpable)
                        if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
                                list_add(&page->lru, &l_active);
                                continue;

> > 
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -608,8 +608,15 @@ static enum page_references page_check_references(struct page *page,
> > > >  		 * quickly recovered.
> > > >  		 */
> > > >  		SetPageReferenced(page);
> > > > -
> > > > -		if (referenced_page)
> > > > +		/*
> > > > +		 * Identify pte referenced and file-backed pages and give them
> > > > +		 * one trip around the active list. So that executable code get
> > > > +		 * better chances to stay in memory under moderate memory
> > > > +		 * pressure. JVM can create lots of anon VM_EXEC pages, so we
> > > > +		 * ignore them here.
> > > > +               if (referenced_page || ((vm_flags & VM_EXEC) &&
> > > > +                   page_is_file_cache(page)))
> > > >                         return PAGEREF_ACTIVATE;

> > > 
> > > PTE-referenced PageAnon() pages are activated unconditionally a few
> > > lines further up, so the page_is_file_cache() check filters only shmem
> > > pages.  I doubt this was your intention...?
> > This is intented. the executable page protect is just to protect
> > executable file pages. please see 8cab4754d24a0f.
> 
> 8cab4754d24a0f was using !PageAnon() but your one are using page_is_file_cache.
> 8cab4754d24a0f doesn't tell us the reason of the change, no?

What if the executable file happen to be on tmpfs?  The !PageAnon()
test also covers that case. The page_is_file_cache() test here seems
unnecessary. And it looks better to move the VM_EXEC test above the
SetPageReferenced() line to avoid possible side effects.

Thanks,
Fengguang

--DocE+STaALJfprDB
Content-Type: application/x-sh
Content-Disposition: attachment; filename="run-many-x-apps.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/zsh=0A# why zsh? bash does not support floating numbers=0A=0A# aptit=
ude install wmctrl iceweasel gnome-games gnome-control-center=0A# aptitude =
install openoffice.org # and uncomment the oo* lines=0A=0A=0Aread T0 T1 < /=
proc/uptime=0A=0Afunction progress()=0A{=0A	read t0 t1 < /proc/uptime=0A	t=
=3D$((t0 - T0))=0A	printf "%8.2f    " $t=0A	echo "$@"=0A}=0A=0Afunction swi=
tch_windows()=0A{=0A	wmctrl -l | while read a b c win=0A	do=0A		progress A =
"$win"=0A		wmctrl -a "$win"=0A	done=0A	# firefox /usr/share/doc/debian/FAQ/=
index.html=0A}=0A=0Awhile read app args=0Ado=0A	progress N $app $args=0A	pi=
dof $app || $app $args &=0A	switch_windows=0Adone << EOF=0Axeyes=0Afirefox=
=0Anautilus=0Anautilus --browser=0Agthumb=0Agedit=0Axpdf /usr/share/doc/sha=
red-mime-info/shared-mime-info-spec.pdf=0A=0Axterm=0Amlterm=0Agnome-termina=
l=0Aurxvt=0A=0Agnome-system-monitor=0Agnome-help=0Agnome-dictionary=0A=0A/u=
sr/games/sol=0A/usr/games/gnometris=0A/usr/games/gnect=0A/usr/games/gtali=
=0A/usr/games/iagno=0A/usr/games/gnotravex=0A/usr/games/mahjongg=0A/usr/gam=
es/gnome-sudoku=0A/usr/games/glines=0A/usr/games/glchess=0A/usr/games/gnomi=
ne=0A/usr/games/gnotski=0A/usr/games/gnibbles=0A/usr/games/gnobots2=0A/usr/=
games/blackjack=0A/usr/games/same-gnome=0A=0A/usr/bin/gnome-window-properti=
es=0A/usr/bin/gnome-default-applications-properties=0A/usr/bin/gnome-at-pro=
perties=0A/usr/bin/gnome-typing-monitor=0A/usr/bin/gnome-at-visual=0A/usr/b=
in/gnome-sound-properties=0A/usr/bin/gnome-at-mobility=0A/usr/bin/gnome-key=
binding-properties=0A/usr/bin/gnome-about-me=0A/usr/bin/gnome-display-prope=
rties=0A/usr/bin/gnome-network-preferences=0A/usr/bin/gnome-mouse-propertie=
s=0A/usr/bin/gnome-appearance-properties=0A/usr/bin/gnome-control-center=0A=
/usr/bin/gnome-keyboard-properties=0A=0A: oocalc=0A: oodraw=0A: ooimpress=
=0A: oomath=0A: ooweb=0A: oowriter    =0A=0AEOF=0A
--DocE+STaALJfprDB
Content-Type: application/x-sh
Content-Disposition: attachment; filename="test-mmap-exec-prot.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/sh=0A=0Aprot=3D$(</proc/sys/fs/suid_dumpable)=0Aecho $prot=0A=0ADISP=
LAY=3D:0.0 ./run-many-x-apps.sh > progress.$prot=0A=0Acp /proc/vmstat vmsta=
t.$prot=0Acp /proc/meminfo meminfo.$prot=0Admesg > dmesg.$prot=0Afree > fre=
e.$prot=0A
--DocE+STaALJfprDB
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
--DocE+STaALJfprDB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
