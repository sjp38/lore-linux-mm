Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id ACB086B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 03:48:20 -0400 (EDT)
Date: Wed, 12 Aug 2009 15:48:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090812074820.GA29631@localhost>
References: <20090806100824.GO23385@random.random> <4A7AD5DF.7090801@redhat.com> <20090807121443.5BE5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="G4iJoqBmSsgzjUCe"
Content-Disposition: inline
In-Reply-To: <20090807121443.5BE5.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Aug 07, 2009 at 11:17:22AM +0800, KOSAKI Motohiro wrote:
> > Andrea Arcangeli wrote:
> > 
> > > Likely we need a cut-off point, if we detect it takes more than X
> > > seconds to scan the whole active list, we start ignoring young bits,
> > 
> > We could just make this depend on the calculated inactive_ratio,
> > which depends on the size of the list.
> > 
> > For small systems, it may make sense to make every accessed bit
> > count, because the working set will often approach the size of
> > memory.
> > 
> > On very large systems, the working set may also approach the
> > size of memory, but the inactive list only contains a small
> > percentage of the pages, so there is enough space for everything.
> > 
> > Say, if the inactive_ratio is 3 or less, make the accessed bit
> > on the active lists count.
> 
> Sound reasonable.

Yes, such kind of global measurements would be much better.

> How do we confirm the idea correctness?

In general the active list tends to grow large on under-scanned LRU.
I guess Rik is pretty familiar with typical inactive_ratio values of
the large memory systems and may even have some real numbers :)

> Wu, your X focus switching benchmark is sufficient test?

It is a major test case for memory tight desktop.  Jeff presents
another interesting one for KVM, hehe.

Anyway I collected the active/inactive list sizes, and the numbers
show that the inactive_ratio is roughly 1 when the LRU is scanned
actively and may go very high when it is under-scanned.

Thanks,
Fengguang


4GB desktop, kernel 2.6.30
--------------------------

1) fresh startup:

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
                0            80255            68932            24066

2) read 10GB sparse file:

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            48096            52312           830142            10971

3) kvm -m 512M:

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            82606           155588           684375            15380

4) exit kvm:

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            66364            35275           679033            17009


512MB desktop, kernel 2.6.31
----------------------------

1) fresh startup, console:

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
                0             1870             7082             2075

2) fresh startx:

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
                0            30021            31551             6893

3) start many x apps, no swap:
   (script attached)

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
                0            56475            29608             9707
             4074            54886            27431             9743
             5452            54025            26685             9950
             7417            53428            25394             9963
             8522            52388            24717            10553
            10684            51955            22055            11384
            11644            51597            21329            11342
            12341            51221            20822            11513
            13874            49738            19916            11516
            13874            50494            19916            11517
            15284            48778            19739            12127
            15668            49037            19196            12380
            16821            48571            17661            13133
            18329            49175            14470            14490
            18961            49652            13081            14432
            18961            49608            13236            14414
            20563            51379            11171            13823
            21044            50281            10311            13948
            21426            49906            10268            13984
            21771            50479             9734            14019
            23246            49062             9672            13431
            23984            49490            10083            12763
            24479            49373            10332            12446
            25782            49053             9655            12101

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            26970            48078             9891            11415
            28041            47873             9617            11079
            29485            51183             8445             8293
            30484            50140             8441             7997
            31841            50578             6904             7413
            32579            49873             6937             7804
            34117            49336             6447             7440
            35380            48300             5816             7471
            38055            46486             4778             7546
            39528            45227             5043             7417
            40777            44681             4148             7325
            41902            44468             3967             6534
            43107            43378             4630             5846
            43418            43538             5019             5698
            43563            43514             4839             5514
            43660            43587             5228             5431
            43645            43315             4919             5886
            43618            43555             4531             5704
            43751            43646             4584             5600
            43839            43703             4507             5569
            44015            44057             4757             5378
            44115            44089             4707             4724
            44331            44184             4710             4701
            44577            44554             4221             4265

[...]

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            47945            47876             1594             1547
            47944            47888             1944             1494
            47944            47888             1351             1392
            47974            47844             1976             1498
            47974            47858             1411             1549
            47974            47857             1482             1423
            47973            47874             2105             1435
            47969            47349             1884             1592
            47966            47353             1993             1700
            47966            47343             1913             1882
            47965            47306             1683             1746
            47960            47373             1598             1583
            47960            47375             1808             1677
            47960            47004             2444             1625
            47959            47060             2017             1825
            47956            47047             1866             1742
            47955            47080             2039             1987
            47954            47072             1734             1822
            47954            47092             1963             1867
            47954            47130             1851             1846
            47954            47154             2134             1813
            47954            47181             1952             1813
            47953            47138             1678             1810
            47951            47125             1848             1951

4) start many x apps, with swap:

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
                0             6571            13646             3251
                0             6823            14637             3900
                0             7426            17187             3935
                0             8188            19989             3959
                0             9994            21582             4148
                0            12556            21889             5157
                0            13846            23764             5249
                0            20383            25393             5546
                0            21830            26019             5696
                0            22856            26608             5972
                0            28651            28128             6146
                0            28058            28482             6309
                0            27726            28595             6312
                0            27634            28775             6471
                0            27636            28774             6464
                0            31299            28848             6834
                0            35102            29539             6886
                0            39561            29980             6915
                0            41573            30008             6917
                0            47562            30041             6917
                0            54603            30041             6917
             3040            55528            29273             6945
            16937            44916            23406             7675
            16937            44932            23416             7670

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            16937            44961            23416             7670
            16937            40583            23416             7670
            16937            40596            23417             7670
            16937            40607            23417             7670
            16937            40139            23404             7668
            12181            11794            22932             8144
            12181            11794            22932             8144
            12181            11794            22946             8144
            12181            11794            22946             8144
            12147            13063            23148             8280
            12146            15994            22842             8565
            12146            17491            22654             8718
            12146            17488            22654             8718
            12146            17653            22634             8733
            12146            18656            21030            10513
            12146            19717            20778            10770
            12146            20341            20859            10846
            12146            21134            21096            11133
            12146            22692            21129            11453
            12144            24698            22225            11476
            12144            27726            22609            11536
            12144            27774            22648            11555
            12144            28447            22844            11564
            12144            30286            23238            11567

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            12121            31489            23350            11761
            12099            33117            23336            11779
            12099            33632            23555            11787
            12099            35393            23566            11806
            12099            35828            23490            11882
            12099            35879            23486            11887
            12099            35889            23486            11888
            12099            36078            24124            11890
            12099            36449            25079            11895
            12099            37782            25334            11898
            12099            39494            25564            11904
            12099            40620            25657            11905
            14200            41298            25399            12069
            21555            35228            22969            12495
            22829            33097            22703            12617
            25519            31496            22115            12552
            28590            28947            21617            13051
            28940            29076            19806            13270
            29430            29344            19153            13825
            30183            30399            17643            13418
            32242            32203            13535            13969
            33319            33294            12236            13659
            33154            33085            11431            13482
            33572            33569            11315            13102

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            36246            35355             8033             9355
            35659            35558             8491             8394
            35330            35142             8233             8278
            35788            35561             8460             8454
            36129            36359             8413             8627
            36727            36365             8311             8509
            36672            36870             8437             8479
            36772            36656             8090             8354
            36754            36614             8237             8378
            37591            36065             8352             8470
            36530            36383             7607             7611
            36113            35992             7271             7296
            36149            35667             7092             7052
            36014            35350             7408             7206
            36409            35890             8027             7396
            36300            35418             7892             7704
            36369            36589             7723             7838
            36243            36168             7576             7793
            35804            35622             7422             7726
            35498            35435             7443             7557
            35078            35159             7542             7243
            35478            35415             8199             7552
            35143            35025             7828             7763
            35312            34754             7745             7545

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            35093            34933             7166             7748
            36253            36236             7171             7408
            36225            36929             8236             7532
            36197            36169             7562             7632
            35711            35647             7312             7471
            35210            35144             7202             7227
            35052            35021             7073             7084
            35263            35047             7128             6963
            35359            35177             7572             7048
            35665            35523             7927             7025
            34988            34788             7279             7340
            34678            34438             7352             7141
            34352            34270             7033             6980
            34307            34175             6881             6809
            34038            34469             7603             6700
            34169            33854             7105             6868
            34048            34124             7051             6869
            33630            33445             6821             6875
            33047            32992             6617             6554
            33232            33012             7114             6659
            33442            33217             7408             6700
            32942            32707             6830             7257
            32672            32593             6801             7207
            32406            32142             6656             6960

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            32127            32036             6641             6798
            31929            31769             6567             6664
            31786            31968             7532             6670
            32208            31228             7448             6859
            30904            30835             6503             6774
            30543            30559             6345             6709
            30394            30278             6235             6288
            30541            30239             6470             6243
            30463            30656             6959             6587
            31020            29794             7393             6897
            30169            30128             6295             6905
            29755            29644             6236             6598
            29765            29617             6342             6475
            29874            29748             6215             6335
            29654            29491             6355             6358
            29972            29853             7079             6607
            29437            29267             6670             7205
            29160            28956             6602             6982
            29411            29017             6578             6937
            29069            28952             6539             6717
            29570            29342             6982             6850
            28882            28927             6912             6809
            29326            28731             6928             6814
            28883            28817             6762             6819

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            29072            28696             6756             6803
            29296            29120             6993             6972
            28426            28167             6238             7182
            28071            27862             6197             6953
            27944            27767             6872             6780
            28141            27819             6839             6654
            27547            27309             6285             6209
            27578            27842             7730             6465
            27741            27470             7180             6665
            27481            27217             7566             6919
            27568            27405             7696             7027
            27274            27004             7416             7120
            27110            26920             7111             7303
            27282            27056             7476             7046
            27549            27044             7779             7074
            27325            26968             7290             6972
            27665            27528             8465             7058
            27093            26974             7662             7243
            27155            27068             7299             7344
            26638            26553             6925             7325
            26718            26383             6571             7425
            26264            26150             6470             6960
            26463            26176             6590             6803
            27155            26396             7387             6709

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            26532            26408             6722             6702
            26491            26421             6789             6731
            26783            26950             8389             6849
            27129            26584             7713             6991
            26791            26228             7316             7202
            26208            26168             7115             7172
            26031            25907             6957             7118
            25980            25675             6764             7216
            25608            25535             6779             7042
            25571            25501             6520             6943
            26068            25287             6574             6948
            25734            25305             6778             6776
            25442            25134             6629             6556
            25514            25217             7469             6543
            25659            25552             8561             6620
            26082            24784             8494             6676
            25312            25194             7052             7026
            25386            25267             7422             6973
            25070            24965             6716             6886
            25143            24801             6597             6785
            24971            24866             6643             6786
            25223            25212             6829             6757
            25504            24778             7589             6840
            25531            24786             8068             6896

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            25343            25169             7227             7042
            25195            25129             6804             7149
            25355            25071             6958             6941
            25294            25202             6676             6850
            25688            25050             6743             6694
            25736            25268             6910             6580
            25750            25530             7299             6557
            25401            25273             6622             6810
            25672            25525             6798             6770
            25192            25067             6226             6486
            26011            25360             6540             6466
            26673            25768             6444             6411
            27211            26326             6370             6423
            27527            26764             6615             6534
            27355            26820             6337             6467
            27385            26962             6098             6446
            27528            27431             5832             6303
            26955            26918             6016             6015
            26816            26469             5847             5894
            26961            26390             6077             5866
            26781            26664             5625             5815
            26755            26454             6114             5806
            26994            26552             6016             5784
            27482            26910             5945             5714

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            27609            27143             5929             5715
            27885            27443             7168             5947
            27684            27635             8231             6145
            27320            27205             7359             6415
            27679            27265             7898             6445
            27655            26342             7651             6574
            27033            26853             7385             6831
            26696            26468             6533             6721
            26464            26310             6374             6465
            26192            26084             6261             6417
            26182            25801             6511             6367
            26010            25880             6251             6266
            26130            26032             5974             6280
            26417            26175             5830             6610
            26558            26450             6002             6623
            26758            26016             6141             6526
            26481            26363             5911             6356
            26765            26622             6401             6266
            27022            26534             6593             6210
            27587            26515             6560             6193
            27156            27029             6123             6109
            27284            26926             6159             5776
            27153            26996             5698             5642
            26712            26603             6151             5541

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            26697            27024             7919             5565
            26651            26471             7134             5965
            27021            26479             7617             5996
            26323            26024             7091             6273
            26081            25894             6267             6527
            25605            25487             5814             6407
            25564            25447             5613             6422
            25460            25406             5630             6374
            25380            25380             5776             6358
            25661            25653             6045             6037
            25790            24706             6069             6045
            25512            25043             6024             5982
            25440            25102             6067             5807
            25802            25181             5953             5838
            25864            25314             5694             5711
            26022            25737             5592             5510
            25964            25741             6784             5376
            26092            25952             7929             5537
            26110            25990             7120             5789
            25311            25252             6157             6146
            25432            25379             6658             6197
            25552            25390             6176             6357
            25388            25237             5742             6303
            25841            25173             5932             6325

 nr_inactive_anon   nr_active_anon nr_inactive_file   nr_active_file
            25054            24965             5532             6072
            24754            25191             7503             5941
            25529            25133             7319             6000
            25350            24510             6993             6078
            24672            24541             6027             6068
            24610            24492             5811             5804
            24819            24674             5841             5820
            24775            24394             5719             5696
            24991            25179             6639             5816
            25282            24538             6870             6088
            25172            24727             6628             6090
            25363            24721             6644             6091
            25676            24705             6672             6102
            24998            24909             5683             5957
            24762            24736             6034             5869
            24965            24890             6374             6614
            25050            24895             6436             6616
            25087            24932             6436             6617
            25139            24860             6435             6619
            25159            24903             6435             6620
            25168            25362             6004             7051
            25209            25524             6004             7052
            25209            25504             6004             7053
            25262            25447             6011             7054

--G4iJoqBmSsgzjUCe
Content-Type: application/x-sh
Content-Disposition: attachment; filename="run-many-x-apps.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/zsh=0A# why zsh? bash does not support floating numbers=0A=0A# aptit=
ude install wmctrl iceweasel gnome-games gnome-control-center=0A# aptitude =
install openoffice.org # and uncomment the oo* lines=0A=0A=0Aread T0 T1 < /=
proc/uptime=0A=0Afunction progress()=0A{=0A	read t0 t1 < /proc/uptime=0A	t=
=3D$((t0 - T0))=0A	printf "%8.2f    " $t=0A	echo "$@"=0A}=0A=0Afunction swi=
tch_windows()=0A{=0A	wmctrl -l | while read a b c win=0A	do=0A		progress A =
"$win"=0A		wmctrl -a "$win"=0A	done=0A	firefox /usr/share/doc/debian/FAQ/in=
dex.html=0A}=0A=0Awhile read app args=0Ado=0A	progress N $app $args=0A	$app=
 $args &=0A	switch_windows=0Adone << EOF=0Axeyes=0Afirefox=0Anautilus=0Anau=
tilus --browser=0Agthumb=0Agedit=0Axpdf /usr/share/doc/shared-mime-info/sha=
red-mime-info-spec.pdf=0A=0Axterm=0Amlterm=0Agnome-terminal=0Aurxvt=0A=0Agn=
ome-system-monitor=0Agnome-help=0Agnome-dictionary=0A=0A/usr/games/sol=0A/u=
sr/games/gnometris=0A/usr/games/gnect=0A/usr/games/gtali=0A/usr/games/iagno=
=0A/usr/games/gnotravex=0A/usr/games/mahjongg=0A/usr/games/gnome-sudoku=0A/=
usr/games/glines=0A/usr/games/glchess=0A/usr/games/gnomine=0A/usr/games/gno=
tski=0A/usr/games/gnibbles=0A/usr/games/gnobots2=0A/usr/games/blackjack=0A/=
usr/games/same-gnome=0A=0A/usr/bin/gnome-window-properties=0A/usr/bin/gnome=
-default-applications-properties=0A/usr/bin/gnome-at-properties=0A/usr/bin/=
gnome-typing-monitor=0A/usr/bin/gnome-at-visual=0A/usr/bin/gnome-sound-prop=
erties=0A/usr/bin/gnome-at-mobility=0A/usr/bin/gnome-keybinding-properties=
=0A/usr/bin/gnome-about-me=0A/usr/bin/gnome-display-properties=0A/usr/bin/g=
nome-network-preferences=0A/usr/bin/gnome-mouse-properties=0A/usr/bin/gnome=
-appearance-properties=0A/usr/bin/gnome-control-center=0A/usr/bin/gnome-key=
board-properties=0A=0A: oocalc=0A: oodraw=0A: ooimpress=0A: oomath=0A: oowe=
b=0A: oowriter    =0A=0AEOF=0A
--G4iJoqBmSsgzjUCe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
