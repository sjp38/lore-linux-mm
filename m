Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 096126B010F
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 15:03:36 -0400 (EDT)
Received: by mail-ve0-f181.google.com with SMTP id pa12so3836511veb.40
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 12:03:35 -0700 (PDT)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 5 Apr 2013 12:03:15 -0700
Message-ID: <CALCETrXMkO-TPJXTOu7pcOkz8pk-2Vny-GVRa4QsDtJU=K5vtA@mail.gmail.com>
Subject: btrfs insane I/O amplification?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-btrfs@vger.kernel.org

I'm on Fedora's 3.8.5-201.fc18.x86_64.  I tried to do some
not-very-heavy I/O on my system (i.e. save kernel/sys.c in emacs) and
it took about a minute.  Everything went downhill from there.  My
system was basically idle at the time.  (I have very little in the way
of diagnostics because I couldn't do much but hit the reset button
after a couple of minutes.)


On restart, dmesg said:

[   10.018204] Btrfs detected SSD devices, enabling SSD mode
[   10.049623] btrfs: free space inode generation (0) did not match
free space cache generation (776515)
[   10.293808] block group 29020389376 has an wrong amount of free space
[   10.293810] btrfs: failed to load free space cache for block group
29020389376
[   10.302647] block group 30094131200 has an wrong amount of free space
[   10.302649] btrfs: failed to load free space cache for block group
30094131200
[   10.364683] block group 55327064064 has an wrong amount of free space
[   10.364685] btrfs: failed to load free space cache for block group
55327064064
[   10.370766] block group 32241614848 has an wrong amount of free space
[   10.370767] btrfs: failed to load free space cache for block group
32241614848
[   10.390152] block group 56535023616 has an wrong amount of free space
[   10.390154] btrfs: failed to load free space cache for block group
56535023616
[   10.398773] block group 33315356672 has an wrong amount of free space
[   10.398774] btrfs: failed to load free space cache for block group
33315356672
[   10.553882] btrfs: unlinked 4 orphans
[   10.553885] btrfs: truncated 2 orphans

...

[   33.507655] btrfs: failed to load free space cache for block group
31167873024
[   33.514853] block group 43381686272 has an wrong amount of free space
[   33.514855] btrfs: failed to load free space cache for block group
43381686272
[   33.519297] block group 50897879040 has an wrong amount of free space
[   33.519299] btrfs: failed to load free space cache for block group
50897879040
[   33.523694] block group 57608765440 has an wrong amount of free space
[   33.523696] btrfs: failed to load free space cache for block group
57608765440
[   33.526537] block group 60964208640 has an wrong amount of free space
[   33.526539] btrfs: failed to load free space cache for block group
60964208640
[   33.529468] block group 70091014144 has an wrong amount of free space
[   33.529469] btrfs: failed to load free space cache for block group
70091014144
[   33.534249] block group 72238497792 has an wrong amount of free space
[   33.534250] btrfs: failed to load free space cache for block group
72238497792
[   33.538112] block group 80962650112 has an wrong amount of free space
[   33.538113] btrfs: failed to load free space cache for block group
80962650112
[   33.546610] block group 82036391936 has an wrong amount of free space
[   33.546612] btrfs: failed to load free space cache for block group
82036391936
[   33.552208] block group 83110133760 has an wrong amount of free space
[   33.552210] btrfs: failed to load free space cache for block group
83110133760

etc.


block_dump said, during the problem:

[83609.668785] btrfs-transacti(726): WRITE block 78521360 on dm-3 (112
sectors) [83609.668811] btrfs-transacti(726): WRITE block 78259328 on
dm-3 (128 sectors) [83609.668814] btrfs-transacti(726): WRITE block
78521472 on dm-3 (128 sectors) [83609.668834] btrfs-submit-1(693):
WRITE block 45092536 on dm-3 (1024 sectors) [83609.668839]
btrfs-transacti(726): WRITE block 78259456 on dm-3 (128 sectors)
[83609.668842] btrfs-transacti(726): WRITE block 78521600 on dm-3 (128
sectors) [83609.668849] btrfs-transacti(726): WRITE block 78259584 on
dm-3 (24 sectors) [83609.668852] btrfs-transacti(726): WRITE block
78521728 on dm-3 (24 sectors) [83609.668860] btrfs-transacti(726):
WRITE block 78259616 on dm-3 (16 sectors) [83609.668862]
btrfs-transacti(726): WRITE block 78521760 on dm-3 (16 sectors)
[83609.668868] btrfs-submit-1(693): WRITE block 45093560 on dm-3 (600
sectors) [83609.668882] btrfs-transacti(726): WRITE block 78259640 on
dm-3 (72 sectors) [83609.668884] btrfs-transacti(726): WRITE block
78521784 on dm-3 (72 sectors) [83609.668910] btrfs-transacti(726):
WRITE block 78259712 on dm-3 (128 sectors) [83609.668912]
btrfs-transacti(726): WRITE block 78521856 on dm-3 (128 sectors)
[83609.668921] btrfs-transacti(726): WRITE block 78259840 on dm-3 (32
sectors) [83609.668925] btrfs-transacti(726): WRITE block 78521984 on
dm-3 (32 sectors) [83609.668934] btrfs-transacti(726): WRITE block
78259880 on dm-3 (32 sectors) [83609.668936] btrfs-transacti(726):
WRITE block 78522024 on dm-3 (32 sectors) [83609.668946]
btrfs-transacti(726): WRITE block 78260072 on dm-3 (24 sectors)
[83609.668948] btrfs-transacti(726): WRITE block 78522216 on dm-3 (24
sectors) [83609.668962] btrfs-transacti(726): WRITE block 78260096 on
dm-3 (64 sectors) [83609.668965] btrfs-transacti(726): WRITE block
78522240 on dm-3 (64 sectors) [83609.668976] btrfs-transacti(726):
WRITE block 78260168 on dm-3 (40 sectors) [83609.668981]
btrfs-transacti(726): WRITE block 78522312 on dm-3 (40 sectors)
[83609.668983] btrfs-submit-1(693): WRITE block 45163176 on dm-3 (1024
sectors) [83609.668990] btrfs-transacti(726): WRITE block 78260320 on
dm-3 (16 sectors) [83609.668992] btrfs-transacti(726): WRITE block
78522464 on dm-3 (16 sectors) [83609.669004] btrfs-transacti(726):
WRITE block 78260344 on dm-3 (8 sectors) [83609.669007]
btrfs-transacti(726): WRITE block 78522488 on dm-3 (8 sectors)
[83609.669020] btrfs-transacti(726): WRITE block 78260352 on dm-3 (56
sectors) [83609.669022] btrfs-transacti(726): WRITE block 78522496 on
dm-3 (56 sectors) [83609.669025] btrfs-submit-1(693): WRITE block
45164200 on dm-3 (600 sectors) [83609.669036] btrfs-transacti(726):
WRITE block 78260416 on dm-3 (56 sectors) [83609.669040]
btrfs-transacti(726): WRITE block 78522560 on dm-3 (56 sectors)
[83609.669053] btrfs-transacti(726): WRITE block 78260608 on dm-3 (56
sectors) [83609.669155] btrfs-submit-1(693): WRITE block 46260712 on
dm-3 (1024 sectors) [83609.669199] btrfs-submit-1(693): WRITE block
46261736 on dm-3 (600 sectors) [83609.669302] btrfs-submit-1(693):
WRITE block 48243080 on dm-3 (1024 sectors) [83609.669345]
btrfs-submit-1(693): WRITE block 48244104 on dm-3 (592 sectors)
[83609.669454] btrfs-submit-1(693): WRITE block 48549320 on dm-3 (1024
sectors) [83609.669497] btrfs-submit-1(693): WRITE block 48550344 on
dm-3 (592 sectors) [83609.669642] btrfs-submit-1(693): WRITE block
48704512 on dm-3 (1024 sectors) [83609.669647] btrfs-submit-1(693):
WRITE block 48705536 on dm-3 (592 sectors) [83609.669707]
btrfs-submit-1(693): WRITE block 50439240 on dm-3 (704 sectors)
[83609.669787] btrfs-submit-1(693): WRITE block 50439944 on dm-3 (912
sectors) [83609.669881] btrfs-submit-1(693): WRITE block 50821240 on
dm-3 (1024 sectors) [83609.669925] btrfs-submit-1(693): WRITE block
50822264 on dm-3 (592 sectors) [83609.670017] btrfs-submit-1(693):
WRITE block 53286544 on dm-3 (1024 sectors) [83609.670066]
btrfs-submit-1(693): WRITE block 53287568 on dm-3 (584 sectors)
[83609.670171] btrfs-submit-1(693): WRITE block 55898712 on dm-3 (1024
sectors) [83609.670215] btrfs-submit-1(693): WRITE block 55899736 on
dm-3 (584 sectors) [83609.670304] btrfs-submit-1(693): WRITE block
58748840 on dm-3 (1024 sectors) [83609.671087] btrfs-submit-1(693):
WRITE block 58749864 on dm-3 (584 sectors) [83609.671095]
btrfs-submit-1(693): WRITE block 61608344 on dm-3 (1024 sectors)
[83609.671102] btrfs-submit-1(693): WRITE block 61609368 on dm-3 (584
sectors) [83609.671105] btrfs-submit-1(693): WRITE block 61785280 on
dm-3 (1024 sectors) [83609.671109] btrfs-submit-1(693): WRITE block
61786304 on dm-3 (584 sectors) [83609.671112] btrfs-submit-1(693):
WRITE block 63055872 on dm-3 (1024 sectors) [83609.671116]
btrfs-submit-1(693): WRITE block 63056896 on dm-3 (576 sectors)
[83609.671120] btrfs-submit-1(693): WRITE block 63061064 on dm-3 (1024
sectors) [83609.671123] btrfs-submit-1(693): WRITE block 63062088 on
dm-3 (576 sectors) [83609.671126] btrfs-submit-1(693): WRITE block
63066648 on dm-3 (1024 sectors) [83609.671131] btrfs-submit-1(693):
WRITE block 63067672 on dm-3 (576 sectors) [83609.672094]
btrfs-transacti(726): WRITE block 78522752 on dm-3 (56 sectors)
[83609.672178] btrfs-submit-1(693): WRITE block 63077440 on dm-3 (1024
sectors) [83609.672185] btrfs-submit-1(693): WRITE block 63078464 on
dm-3 (72 sectors) [83609.672190] btrfs-submit-1(693): WRITE block
63078536 on dm-3 (504 sectors) [83609.672194] btrfs-submit-1(693):
WRITE block 63146632 on dm-3 (1024 sectors) [83609.672198]
btrfs-submit-1(693): WRITE block 63147656 on dm-3 (576 sectors)
[83609.672202] btrfs-submit-1(693): WRITE block 63188400 on dm-3 (1024
sectors) [83609.672206] btrfs-submit-1(693): WRITE block 63189424 on
dm-3 (568 sectors) [83609.672210] btrfs-submit-1(693): WRITE block
63360104 on dm-3 (1024 sectors) [83609.672213] btrfs-submit-1(693):
WRITE block 63361128 on dm-3 (568 sectors) [83609.672219]
btrfs-submit-1(693): WRITE block 63367472 on dm-3 (1024 sectors)
[83609.672222] btrfs-submit-1(693): WRITE block 63368496 on dm-3 (568
sectors) [83609.672226] btrfs-submit-1(693): WRITE block 63373424 on
dm-3 (1024 sectors) [83609.672229] btrfs-transacti(726): WRITE block
78260728 on dm-3 (8 sectors) [83609.672230] btrfs-submit-1(693): WRITE
block 63374448 on dm-3 (568 sectors) [83609.672236]
btrfs-transacti(726): WRITE block 78522872 on dm-3 (8 sectors)
[83609.672237] btrfs-submit-1(693): WRITE block 63421496 on dm-3 (1024
sectors) [83609.672240] btrfs-submit-1(693): WRITE block 63422520 on
dm-3 (568 sectors) [83609.672300] btrfs-transacti(726): WRITE block
78260736 on dm-3 (128 sectors) [83609.672307] btrfs-transacti(726):
WRITE block 78522880 on dm-3 (128 sectors) [83609.672585]
btrfs-transacti(726): WRITE block 78260864 on dm-3 (128 sectors)
[83609.672590] btrfs-transacti(726): WRITE block 78523008 on dm-3 (128
sectors) [83609.672862] btrfs-transacti(726): WRITE block 78260992 on
dm-3 (80 sectors) [83609.672868] btrfs-transacti(726): WRITE block
78523136 on dm-3 (80 sectors) [83609.673041] btrfs-transacti(726):
WRITE block 78261080 on dm-3 (40 sectors) [83609.673046]
btrfs-transacti(726): WRITE block 78523224 on dm-3 (40 sectors)
[83609.673153] btrfs-transacti(726): WRITE block 78261120 on dm-3 (24
sectors) [83609.673158] btrfs-transacti(726): WRITE block 78523264 on
dm-3 (24 sectors) [83609.673231] btrfs-transacti(726): WRITE block
78261152 on dm-3 (64 sectors) [83609.673235] btrfs-transacti(726):
WRITE block 78523296 on dm-3 (64 sectors) [83609.673375]
btrfs-transacti(726): WRITE block 78261224 on dm-3 (24 sectors)
[83609.673381] btrfs-transacti(726): WRITE block 78523368 on dm-3 (24
sectors) [83609.673440] btrfs-transacti(726): WRITE block 78261248 on
dm-3 (8 sectors) [83609.673445] btrfs-transacti(726): WRITE block
78523392 on dm-3 (8 sectors) [83609.673478] btrfs-transacti(726):
WRITE block 78261304 on dm-3 (8 sectors) [83609.673483]
btrfs-transacti(726): WRITE block 78523448 on dm-3 (8 sectors)
[83609.673521] btrfs-transacti(726): WRITE block 78261320 on dm-3 (32
sectors) [83609.673526] btrfs-transacti(726): WRITE block 78523464 on
dm-3 (32 sectors) [83609.673605] btrfs-transacti(726): WRITE block
78261696 on dm-3 (16 sectors) [83609.673610] btrfs-transacti(726):
WRITE block 78523840 on dm-3 (16 sectors) [83609.673663]
btrfs-transacti(726): WRITE block 78262016 on dm-3 (24 sectors)
[83609.673669] btrfs-transacti(726): WRITE block 78524160 on dm-3 (24
sectors) [83609.673734] btrfs-transacti(726): WRITE block 78262248 on
dm-3 (24 sectors) [83609.673739] btrfs-transacti(726): WRITE block
78524392 on dm-3 (24 sectors) [83609.673806] btrfs-transacti(726):
WRITE block 78262272 on dm-3 (24 sectors) [83609.673811]
btrfs-transacti(726): WRITE block 78524416 on dm-3 (24 sectors)
[83609.673887] btrfs-transacti(726): WRITE block 78262592 on dm-3 (64
sectors) [83609.673892] btrfs-transacti(726): WRITE block 78524736 on
dm-3 (64 sectors) [83609.674064] btrfs-transacti(726): WRITE block
78262656 on dm-3 (128 sectors) [83609.674072] btrfs-transacti(726):
WRITE block 78524800 on dm-3 (128 sectors) [83609.674101]
btrfs-submit-1(693): WRITE block 63547728 on dm-3 (1024 sectors)
[83609.674111] btrfs-submit-1(693): WRITE block 63548752 on dm-3 (560
sectors) [83609.674115] btrfs-submit-1(693): WRITE block 63578680 on
dm-3 (1024 sectors) [83609.674119] btrfs-submit-1(693): WRITE block
63579704 on dm-3 (560 sectors) [83609.674123] btrfs-submit-1(693):
WRITE block 63581232 on dm-3 (1024 sectors) [83609.674128]
btrfs-submit-1(693): WRITE block 63582256 on dm-3 (560 sectors)
[83609.674133] btrfs-submit-1(693): WRITE block 63891960 on dm-3 (1024
sectors) [83609.674137] btrfs-submit-1(693): WRITE block 63892984 on
dm-3 (560 sectors) [83609.674141] btrfs-submit-1(693): WRITE block
64181824 on dm-3 (64 sectors) [83609.674145] btrfs-submit-1(693):
WRITE block 64181888 on dm-3 (1024 sectors) [83609.674150]
btrfs-submit-1(693): WRITE block 64182912 on dm-3 (496 sectors)
[83609.674154] btrfs-submit-1(693): WRITE block 64185792 on dm-3 (1024
sectors) [83609.674158] btrfs-submit-1(693): WRITE block 64186816 on
dm-3 (552 sectors) [83609.674162] btrfs-submit-1(693): WRITE block
64823296 on dm-3 (1024 sectors) [83609.674167] btrfs-submit-1(693):
WRITE block 64824320 on dm-3 (552 sectors) [83609.674171]
btrfs-submit-1(693): WRITE block 64894544 on dm-3 (1024 sectors)
[83609.674174] btrfs-submit-1(693): WRITE block 64895568 on dm-3 (552
sectors) [83609.674178] btrfs-submit-1(693): WRITE block 65033992 on
dm-3 (1024 sectors) [83609.674183] btrfs-submit-1(693): WRITE block
65035016 on dm-3 (552 sectors) [83609.674187] btrfs-submit-1(693):
WRITE block 65045928 on dm-3 (1024 sectors) [83609.674191]
btrfs-submit-1(693): WRITE block 65046952 on dm-3 (552 sectors)
[83609.674195] btrfs-submit-1(693): WRITE block 65056784 on dm-3 (1024
sectors) [83609.674200] btrfs-submit-1(693): WRITE block 65057808 on
dm-3 (544 sectors) [83609.674204] btrfs-submit-1(693): WRITE block
65954784 on dm-3 (1024 sectors) [83609.674208] btrfs-submit-1(693):
WRITE block 65955808 on dm-3 (544 sectors) [83609.674211]
btrfs-submit-1(693): WRITE block 65971976 on dm-3 (1024 sectors)
[83609.674216] btrfs-submit-1(693): WRITE block 65973000 on dm-3 (544
sectors) [83609.674262] btrfs-submit-1(693): WRITE block 66051944 on
dm-3 (1024 sectors) [83609.674313] btrfs-submit-1(693): WRITE block
66052968 on dm-3 (544 sectors) [83609.674336] btrfs-transacti(726):
WRITE block 78262784 on dm-3 (64 sectors) [83609.674342]
btrfs-transacti(726): WRITE block 78524928 on dm-3 (64 sectors)
[83609.674394] btrfs-submit-1(693): WRITE block 66073784 on dm-3 (792
sectors) [83609.674470] btrfs-submit-1(693): WRITE block 66074576 on
dm-3 (776 sectors) [83609.674500] btrfs-transacti(726): WRITE block
78262968 on dm-3 (72 sectors) [83609.674506] btrfs-transacti(726):
WRITE block 78525112 on dm-3 (72 sectors) [83609.674574]
btrfs-submit-1(693): WRITE block 66115840 on dm-3 (1024 sectors)
[83609.674632] btrfs-submit-1(693): WRITE block 66116864 on dm-3 (544
sectors) [83609.674677] btrfs-transacti(726): WRITE block 78263040 on
dm-3 (88 sectors) [83609.674683] btrfs-transacti(726): WRITE block
78525184 on dm-3 (88 sectors) [83609.674733] btrfs-submit-1(693):
WRITE block 66144856 on dm-3 (1024 sectors) [83609.674787]
btrfs-submit-1(693): WRITE block 66145880 on dm-3 (536 sectors)
[83609.674864] btrfs-transacti(726): WRITE block 78263160 on dm-3 (8
sectors) [83609.674871] btrfs-transacti(726): WRITE block 78525304 on
dm-3 (8 sectors) [83609.674888] btrfs-submit-1(693): WRITE block
66188144 on dm-3 (1024 sectors) [83609.674929] btrfs-transacti(726):
WRITE block 78263184 on dm-3 (96 sectors) [83609.674934]
btrfs-transacti(726): WRITE block 78525328 on dm-3 (96 sectors)
[83609.674942] btrfs-submit-1(693): WRITE block 66189168 on dm-3 (536
sectors) [83609.675043] btrfs-submit-1(693): WRITE block 66651704 on
dm-3 (1024 sectors) [83609.675105] btrfs-submit-1(693): WRITE block
66652728 on dm-3 (536 sectors) [83609.675134] btrfs-transacti(726):
WRITE block 78263288 on dm-3 (8 sectors) [83609.675139]
btrfs-transacti(726): WRITE block 78525432 on dm-3 (8 sectors)
[83609.675186] btrfs-transacti(726): WRITE block 78263296 on dm-3 (80
sectors) [83609.675191] btrfs-transacti(726): WRITE block 78525440 on
dm-3 (80 sectors) [83609.675206] btrfs-submit-1(693): WRITE block
68308552 on dm-3 (1024 sectors) [83609.675260] btrfs-submit-1(693):
WRITE block 68309576 on dm-3 (536 sectors) [83609.675269]
btrfs-endio-wri(23576): READ block 69388672 on dm-3 (8 sectors)
[83609.675357] btrfs-submit-1(693): WRITE block 68324432 on dm-3 (1024
sectors) [83609.675384] btrfs-transacti(726): WRITE block 78263448 on
dm-3 (104 sectors) [83609.675390] btrfs-transacti(726): WRITE block
78525592 on dm-3 (104 sectors) [83609.675434] btrfs-submit-1(693):
WRITE block 68325456 on dm-3 (536 sectors) [83609.675514]
btrfs-submit-1(693): WRITE block 68334360 on dm-3 (1024 sectors)
[83609.675555] btrfs-submit-1(693): WRITE block 68335384 on dm-3 (528
sectors) [83609.675619] btrfs-transacti(726): WRITE block 78263552 on
dm-3 (80 sectors) [83609.675625] btrfs-transacti(726): WRITE block
78525696 on dm-3 (80 sectors) [83609.675636] btrfs-submit-1(693):
WRITE block 68338040 on dm-3 (1024 sectors) [83609.675677]
btrfs-submit-1(693): WRITE block 68339064 on dm-3 (528 sectors)
[83609.675757] btrfs-submit-1(693): WRITE block 68358336 on dm-3 (1024
sectors) [83609.675798] btrfs-submit-1(693): WRITE block 68359360 on
dm-3 (528 sectors) [83609.675800] btrfs-transacti(726): WRITE block
78263648 on dm-3 (32 sectors) [83609.675804] btrfs-transacti(726):
WRITE block 78525792 on dm-3 (32 sectors) [83609.675879]
btrfs-submit-1(693): WRITE block 68368112 on dm-3 (1024 sectors)
[83609.675906] btrfs-transacti(726): WRITE block 78263688 on dm-3 (104
sectors) [83609.675911] btrfs-transacti(726): WRITE block 78525832 on
dm-3 (104 sectors) [83609.675922] btrfs-submit-1(693): WRITE block
68369136 on dm-3 (528 sectors) [83609.675933] btrfs-submit-1(693):
WRITE block 68371504 on dm-3 (112 sectors) [83609.676011]
btrfs-submit-1(693): WRITE block 68371616 on dm-3 (1024 sectors)
[83609.676045] btrfs-submit-1(693): WRITE block 68372640 on dm-3 (416
sectors) [83609.676127] btrfs-transacti(726): WRITE block 78263800 on
dm-3 (8 sectors) [83609.676138] btrfs-transacti(726): WRITE block
78525944 on dm-3 (8 sectors) [83609.676140] btrfs-submit-1(693): WRITE
block 68452592 on dm-3 (1024 sectors) [83609.676180]
btrfs-transacti(726): WRITE block 78263808 on dm-3 (40 sectors)
[83609.676181] btrfs-submit-1(693): WRITE block 68453616 on dm-3 (520
sectors) [83609.676186] btrfs-transacti(726): WRITE block 78525952 on
dm-3 (40 sectors) [83609.676260] btrfs-submit-1(693): WRITE block
68464032 on dm-3 (1024 sectors) [83609.676288] btrfs-transacti(726):
WRITE block 78263864 on dm-3 (48 sectors) [83609.676293]
btrfs-transacti(726): WRITE block 78526008 on dm-3 (48 sectors)
[83609.676302] btrfs-submit-1(693): WRITE block 68465056 on dm-3 (520
sectors) [83609.676382] btrfs-submit-1(693): WRITE block 68587584 on
dm-3 (1024 sectors) [83609.676419] btrfs-transacti(726): WRITE block
78263984 on dm-3 (80 sectors) [83609.676424] btrfs-submit-1(693):
WRITE block 68588608 on dm-3 (520 sectors) [83609.676425]
btrfs-transacti(726): WRITE block 78526128 on dm-3 (80 sectors)
[83609.676503] btrfs-submit-1(693): WRITE block 68591016 on dm-3 (1024
sectors) [83609.676543] btrfs-submit-1(693): WRITE block 68592040 on
dm-3 (520 sectors) [83609.676615] btrfs-transacti(726): WRITE block
78264064 on dm-3 (120 sectors) [83609.676622] btrfs-transacti(726):
WRITE block 78526208 on dm-3 (120 sectors) [83609.676623]
btrfs-submit-1(693): WRITE block 68605000 on dm-3 (1024 sectors)
[83609.676664] btrfs-submit-1(693): WRITE block 68606024 on dm-3 (520
sectors) [83609.676740] btrfs-submit-1(693): WRITE block 68729432 on
dm-3 (1024 sectors) [83609.676781] btrfs-submit-1(693): WRITE block
68730456 on dm-3 (512 sectors) [83609.676859] btrfs-transacti(726):
WRITE block 78264192 on dm-3 (8 sectors) [83609.676865]
btrfs-transacti(726): WRITE block 78526336 on dm-3 (8 sectors)
[83609.676885] btrfs-submit-1(693): WRITE block 72561000 on dm-3 (1024
sectors) [83609.676904] btrfs-transacti(726): WRITE block 78264296 on
dm-3 (24 sectors) [83609.676909] btrfs-transacti(726): WRITE block
78526440 on dm-3 (24 sectors) [83609.676928] btrfs-submit-1(693):
WRITE block 72562024 on dm-3 (512 sectors) [83609.676976]
btrfs-transacti(726): WRITE block 78264320 on dm-3 (128 sectors)
[83609.676981] btrfs-transacti(726): WRITE block 78526464 on dm-3 (128
sectors) [83609.676992] btrfs-transacti(726): WRITE block 78264448 on
dm-3 (8 sectors) [83609.676998] btrfs-transacti(726): WRITE block
78526592 on dm-3 (8 sectors) [83609.677009] btrfs-transacti(726):
WRITE block 78264480 on dm-3 (8 sectors) [83609.677014]
btrfs-transacti(726): WRITE block 78526624 on dm-3 (8 sectors)
[83609.677027] btrfs-transacti(726): WRITE block 78264512 on dm-3 (8
sectors) [83609.677031] btrfs-transacti(726): WRITE block 78526656 on
dm-3 (8 sectors) [83609.677043] btrfs-transacti(726): WRITE block
78264528 on dm-3 (8 sectors) [83609.677047] btrfs-transacti(726):
WRITE block 78526672 on dm-3 (8 sectors) [83609.677050]
btrfs-submit-1(693): WRITE block 74121792 on dm-3 (1024 sectors)
[83609.677068] btrfs-transacti(726): WRITE block 78264552 on dm-3 (24
sectors) [83609.677074] btrfs-transacti(726): WRITE block 78526696 on
dm-3 (24 sectors) [83609.677082] btrfs-submit-1(693): WRITE block
74122816 on dm-3 (512 sectors) [83609.677083] btrfs-transacti(726):
WRITE block 78264576 on dm-3 (8 sectors) [83609.677087]
btrfs-transacti(726): WRITE block 78526720 on dm-3 (8 sectors)
[83609.677120] btrfs-transacti(726): WRITE block 78264592 on dm-3 (88
sectors) [83609.677125] btrfs-transacti(726): WRITE block 78526736 on
dm-3 (88 sectors) [83609.677191] btrfs-submit-1(693): WRITE block
76669904 on dm-3 (1024 sectors) [83609.677232] btrfs-submit-1(693):
WRITE block 76670928 on dm-3 (512 sectors) [83609.677343]
btrfs-submit-1(693): WRITE block 77085840 on dm-3 (1024 sectors)
[83609.677355] btrfs-submit-1(693): WRITE block 77086864 on dm-3 (136
sectors) [83609.677388] btrfs-submit-1(693): WRITE block 77087000 on
dm-3 (376 sectors) [83609.677488] btrfs-submit-1(693): WRITE block
80348520 on dm-3 (1024 sectors) [83609.677530] btrfs-submit-1(693):
WRITE block 80349544 on dm-3 (512 sectors) [83609.677633]
btrfs-submit-1(693): WRITE block 80356120 on dm-3 (1024 sectors)
[83609.677673] btrfs-submit-1(693): WRITE block 80357144 on dm-3 (504
sectors) [83609.677705] btrfs-transacti(726): WRITE block 78264688 on
dm-3 (8 sectors) [83609.677710] btrfs-transacti(726): WRITE block
78526832 on dm-3 (8 sectors) [83609.677742] btrfs-transacti(726):
WRITE block 78264728 on dm-3 (8 sectors) [83609.677748]
btrfs-transacti(726): WRITE block 78526872 on dm-3 (8 sectors)
[83609.677768] btrfs-submit-1(693): WRITE block 80361512 on dm-3 (1024
sectors) [83609.677781] btrfs-transacti(726): WRITE block 78264768 on
dm-3 (8 sectors) [83609.677785] btrfs-transacti(726): WRITE block
78526912 on dm-3 (8 sectors) [83609.677808] btrfs-submit-1(693): WRITE
block 80362536 on dm-3 (504 sectors) [83609.677819]
btrfs-transacti(726): WRITE block 78264792 on dm-3 (8 sectors)
[83609.677824] btrfs-transacti(726): WRITE block 78526936 on dm-3 (8
sectors) [83609.677863] btrfs-transacti(726): WRITE block 78264808 on
dm-3 (8 sectors) [83609.677868] btrfs-transacti(726): WRITE block
78526952 on dm-3 (8 sectors) [83609.677887] btrfs-submit-1(693): WRITE
block 80399512 on dm-3 (1024 sectors) [83609.677901]
btrfs-transacti(726): WRITE block 78264832 on dm-3 (8 sectors)
[83609.677907] btrfs-transacti(726): WRITE block 78526976 on dm-3 (8
sectors) [83609.677928] btrfs-submit-1(693): WRITE block 80400536 on
dm-3 (504 sectors) [83609.677945] btrfs-transacti(726): WRITE block
78264848 on dm-3 (32 sectors) [83609.677951] btrfs-transacti(726):
WRITE block 78526992 on dm-3 (32 sectors) [83609.678010]
btrfs-submit-1(693): WRITE block 81421944 on dm-3 (1024 sectors)
[83609.678033] btrfs-transacti(726): WRITE block 78264888 on dm-3 (24
sectors) [83609.678038] btrfs-transacti(726): WRITE block 78527032 on
dm-3 (24 sectors) [83609.678051] btrfs-submit-1(693): WRITE block
81422968 on dm-3 (504 sectors) [83609.678119] btrfs-transacti(726):
WRITE block 78264928 on dm-3 (32 sectors) [83609.678124]
btrfs-transacti(726): WRITE block 78527072 on dm-3 (32 sectors)
[83609.678137] btrfs-submit-1(693): WRITE block 81743056 on dm-3 (1024
sectors) [83609.678149] emacs(23619): dirtied inode 11513261 (luto) on
dm-3 [83609.678178] btrfs-submit-1(693): WRITE block 81744080 on dm-3
(504 sectors) [83609.678210] btrfs-transacti(726): WRITE block
78264960 on dm-3 (56 sectors) [83609.678217] btrfs-transacti(726):
WRITE block 78527104 on dm-3 (56 sectors) [83609.678258]
btrfs-submit-1(693): WRITE block 81767256 on dm-3 (1024 sectors)
[83609.678298] btrfs-submit-1(693): WRITE block 81768280 on dm-3 (496
sectors) [83609.678343] btrfs-transacti(726): WRITE block 78265024 on
dm-3 (32 sectors) [83609.678348] btrfs-transacti(726): WRITE block
78527168 on dm-3 (32 sectors) [83609.678378] btrfs-submit-1(693):
WRITE block 81826216 on dm-3 (1024 sectors) [83609.678418]
btrfs-submit-1(693): WRITE block 81827240 on dm-3 (496 sectors)
[83609.678429] btrfs-transacti(726): WRITE block 78265064 on dm-3 (16
sectors) [83609.678434] btrfs-transacti(726): WRITE block 78527208 on
dm-3 (16 sectors) [83609.678497] btrfs-transacti(726): WRITE block
78265088 on dm-3 (128 sectors) [83609.678500] btrfs-submit-1(693):
WRITE block 97886440 on dm-3 (1024 sectors) [83609.678502]
btrfs-transacti(726): WRITE block 78527232 on dm-3 (128 sectors)
[83609.678516] btrfs-transacti(726): WRITE block 78265216 on dm-3 (16
sectors) [83609.678521] btrfs-transacti(726): WRITE block 78527360 on
dm-3 (16 sectors) [83609.678542] btrfs-submit-1(693): WRITE block
97887464 on dm-3 (496 sectors) [83609.678553] btrfs-transacti(726):
WRITE block 78265344 on dm-3 (88 sectors) [83609.678558]
btrfs-transacti(726): WRITE block 78527488 on dm-3 (88 sectors)
[83609.678578] btrfs-transacti(726): WRITE block 78265440 on dm-3 (32
sectors) [83609.678585] btrfs-transacti(726): WRITE block 78527584 on
dm-3 (32 sectors) [83609.678623] btrfs-submit-1(693): WRITE block
99851440 on dm-3 (1024 sectors) [83609.678625] btrfs-transacti(726):
WRITE block 78265472 on dm-3 (120 sectors) [83609.678629]
btrfs-transacti(726): WRITE block 78527616 on dm-3 (120 sectors)
[83609.678664] btrfs-submit-1(693): WRITE block 99852464 on dm-3 (496
sectors) [83609.678670] btrfs-transacti(726): WRITE block 78265600 on
dm-3 (128 sectors) [83609.678679] btrfs-transacti(726): WRITE block
78527744 on dm-3 (128 sectors) [83609.678720] btrfs-transacti(726):
WRITE block 78265728 on dm-3 (128 sectors) [83609.678724]
btrfs-transacti(726): WRITE block 78527872 on dm-3 (128 sectors)
[83609.678730] btrfs-submit-1(693): WRITE block 104764864 on dm-3 (832
sectors) [83609.678757] btrfs-transacti(726): WRITE block 78265856 on
dm-3 (96 sectors) [83609.678761] btrfs-transacti(726): WRITE block
78528000 on dm-3 (96 sectors) [83609.678780] btrfs-transacti(726):
WRITE block 78265960 on dm-3 (24 sectors) [83609.678784]
btrfs-transacti(726): WRITE block 78528104 on dm-3 (24 sectors)
[83609.678786] btrfs-submit-1(693): WRITE block 104765696 on dm-3 (688
sectors) [83609.678800] btrfs-transacti(726): WRITE block 78265984 on
dm-3 (24 sectors) [83609.678805] btrfs-transacti(726): WRITE block
78528128 on dm-3 (24 sectors) [83609.678819] btrfs-transacti(726):
WRITE block 78266016 on dm-3 (16 sectors) [83609.678824]
btrfs-transacti(726): WRITE block 78528160 on dm-3 (16 sectors)
[83609.678845] btrfs-transacti(726): WRITE block 78266040 on dm-3 (48
sectors) [83609.678851] btrfs-transacti(726): WRITE block 78528184 on
dm-3 (48 sectors) [83609.678867] btrfs-submit-1(693): WRITE block
106851184 on dm-3 (1024 sectors) [83609.678869] btrfs-transacti(726):
WRITE block 78266096 on dm-3 (16 sectors) [83609.678872]
btrfs-transacti(726): WRITE block 78528240 on dm-3 (16 sectors)
[83609.678886] btrfs-transacti(726): WRITE block 78266112 on dm-3 (8
sectors) [83609.678891] btrfs-transacti(726): WRITE block 78528256 on
dm-3 (8 sectors) [83609.678904] btrfs-transacti(726): WRITE block
78266128 on dm-3 (16 sectors) [83609.678907] btrfs-submit-1(693):
WRITE block 106852208 on dm-3 (496 sectors) [83609.678911]
btrfs-transacti(726): WRITE block 78528272 on dm-3 (16 sectors)
[83609.678929] btrfs-transacti(726): WRITE block 78266160 on dm-3 (32
sectors) [83609.678934] btrfs-transacti(726): WRITE block 78528304 on
dm-3 (32 sectors) [83609.678947] btrfs-transacti(726): WRITE block
78266200 on dm-3 (16 sectors) [83609.678952] btrfs-transacti(726):
WRITE block 78528344 on dm-3 (16 sectors) [83609.678967]
btrfs-transacti(726): WRITE block 78266224 on dm-3 (16 sectors)
[83609.678971] btrfs-transacti(726): WRITE block 78528368 on dm-3 (16
sectors) [83609.678988] btrfs-submit-1(693): WRITE block 112914256 on
dm-3 (1024 sectors) [83609.678990] btrfs-transacti(726): WRITE block
78266240 on dm-3 (48 sectors) [83609.678995] btrfs-transacti(726):
WRITE block 78528384 on dm-3 (48 sectors) [83609.679025]
btrfs-transacti(726): WRITE block 78266296 on dm-3 (72 sectors)
[83609.679029] btrfs-submit-1(693): WRITE block 112915280 on dm-3 (488
sectors) [83609.679031] btrfs-transacti(726): WRITE block 78528440 on
dm-3 (72 sectors) [83609.679079] btrfs-transacti(726): WRITE block
78266368 on dm-3 (128 sectors) [83609.679084] btrfs-transacti(726):
WRITE block 78528512 on dm-3 (128 sectors) [83609.679117]
btrfs-submit-1(693): WRITE block 117158200 on dm-3 (1024 sectors)
[83609.679128] btrfs-transacti(726): WRITE block 78266496 on dm-3 (128
sectors) [83609.679133] btrfs-transacti(726): WRITE block 78528640 on
dm-3 (128 sectors) [83609.679156] btrfs-submit-1(693): WRITE block
117159224 on dm-3 (488 sectors) [83609.679167] btrfs-transacti(726):
WRITE block 78266624 on dm-3 (88 sectors) [83609.679173]
btrfs-transacti(726): WRITE block 78528768 on dm-3 (88 sectors)
[83609.679189] btrfs-transacti(726): WRITE block 78266720 on dm-3 (32
sectors) [83609.679194] btrfs-transacti(726): WRITE block 78528864 on
dm-3 (32 sectors) [83609.679215] btrfs-transacti(726): WRITE block
78266752 on dm-3 (48 sectors) [83609.679220] btrfs-transacti(726):
WRITE block 78528896 on dm-3 (48 sectors) [83609.679235]
btrfs-submit-1(693): WRITE block 117179304 on dm-3 (1024 sectors)
[83609.679250] btrfs-transacti(726): WRITE block 78266808 on dm-3 (72
sectors) [83609.679254] btrfs-transacti(726): WRITE block 78528952 on
dm-3 (72 sectors) [83609.679275] btrfs-submit-1(693): WRITE block
117180328 on dm-3 (488 sectors) [83609.679295] btrfs-transacti(726):
WRITE block 78266880 on dm-3 (128 sectors) [83609.679301]
btrfs-transacti(726): WRITE block 78529024 on dm-3 (128 sectors)
[83609.679317] btrfs-transacti(726): WRITE block 78267008 on dm-3 (32
sectors) [83609.679323] btrfs-transacti(726): WRITE block 78529152 on
dm-3 (32 sectors) [83609.679334] btrfs-transacti(726): WRITE block
78267048 on dm-3 (8 sectors) [83609.679339] btrfs-transacti(726):
WRITE block 78529192 on dm-3 (8 sectors) [83609.679353]
btrfs-submit-1(693): WRITE block 117647144 on dm-3 (1024 sectors)
[83609.679368] btrfs-transacti(726): WRITE block 78267064 on dm-3 (72
sectors) [83609.679373] btrfs-transacti(726): WRITE block 78529208 on
dm-3 (72 sectors) [83609.679384] btrfs-transacti(726): WRITE block
78267136 on dm-3 (8 sectors) [83609.679388] btrfs-transacti(726):
WRITE block 78529280 on dm-3 (8 sectors) [83609.679392]
btrfs-submit-1(693): WRITE block 117648168 on dm-3 (488 sectors)
[83609.679428] btrfs-transacti(726): WRITE block 78267152 on dm-3 (112
sectors) [83609.679434] btrfs-transacti(726): WRITE block 78529296 on
dm-3 (112 sectors) [83609.679473] btrfs-submit-1(693): WRITE block
120118048 on dm-3 (1024 sectors) [83609.679474] btrfs-transacti(726):
WRITE block 78267264 on dm-3 (128 sectors) [83609.679478]
btrfs-transacti(726): WRITE block 78529408 on dm-3 (128 sectors)
[83609.679487] thunderbird(19849): READ block 69347168 on dm-3 (8
sectors) [83609.679509] btrfs-transacti(726): WRITE block 78267392 on
dm-3 (88 sectors) [83609.679514] btrfs-submit-1(693): WRITE block
120119072 on dm-3 (488 sectors) [83609.679515] btrfs-transacti(726):
WRITE block 78529536 on dm-3 (88 sectors) [83609.679534]
btrfs-transacti(726): WRITE block 78267488 on dm-3 (32 sectors)
[83609.679539] btrfs-transacti(726): WRITE block 78529632 on dm-3 (32
sectors) [83609.679549] btrfs-transacti(726): WRITE block 78267520 on
dm-3 (8 sectors) [83609.679556] btrfs-transacti(726): WRITE block
78529664 on dm-3 (8 sectors) [83609.679592] btrfs-transacti(726):
WRITE block 78267544 on dm-3 (104 sectors) [83609.679597]
btrfs-transacti(726): WRITE block 78529688 on dm-3 (104 sectors)
[83609.679639] btrfs-transacti(726): WRITE block 78267648 on dm-3 (128
sectors) [83609.679644] btrfs-transacti(726): WRITE block 78529792 on
dm-3 (128 sectors) [83609.679677] btrfs-transacti(726): WRITE block
78267776 on dm-3 (104 sectors) [83609.679683] btrfs-transacti(726):
WRITE block 78529920 on dm-3 (104 sectors) [83609.679698]
btrfs-transacti(726): WRITE block 78267888 on dm-3 (16 sectors)
[83609.679705] btrfs-transacti(726): WRITE block 78530032 on dm-3 (16
sectors) [83609.679741] btrfs-transacti(726): WRITE block 78267904 on
dm-3 (120 sectors) [83609.679746] btrfs-transacti(726): WRITE block
78530048 on dm-3 (120 sectors) [83609.679791] btrfs-transacti(726):
WRITE block 78268032 on dm-3 (128 sectors) [83609.679796]
btrfs-transacti(726): WRITE block 78530176 on dm-3 (128 sectors)
[83609.679836] btrfs-transacti(726): WRITE block 78268160 on dm-3 (128
sectors) [83609.679840] btrfs-transacti(726): WRITE block 78530304 on
dm-3 (128 sectors) [83609.679883] btrfs-transacti(726): WRITE block
78268288 on dm-3 (128 sectors) [83609.679890] btrfs-transacti(726):
WRITE block 78530432 on dm-3 (128 sectors) [83609.679929]
btrfs-transacti(726): WRITE block 78268416 on dm-3 (128 sectors)
[83609.679934] btrfs-transacti(726): WRITE block 78530560 on dm-3 (128
sectors) [83609.679958] btrfs-submit-1(693): WRITE block 123969632 on
dm-3 (1024 sectors) [83609.679965] btrfs-submit-1(693): WRITE block
123970656 on dm-3 (480 sectors) [83609.679968] btrfs-transacti(726):
WRITE block 78268544 on dm-3 (96 sectors) [83609.679972]
btrfs-submit-1(693): WRITE block 126276744 on dm-3 (1024 sectors)
[83609.679973] btrfs-transacti(726): WRITE block 78530688 on dm-3 (96
sectors) [83609.679979] btrfs-submit-1(693): WRITE block 126277768 on
dm-3 (480 sectors) [83609.679982] btrfs-submit-1(693): WRITE block
134151288 on dm-3 (1024 sectors) [83609.679986] btrfs-transacti(726):
WRITE block 78268672 on dm-3 (8 sectors) [83609.679987]
btrfs-submit-1(693): WRITE block 134152312 on dm-3 (480 sectors)
[83609.679992] btrfs-submit-1(693): WRITE block 134410744 on dm-3
(1024 sectors) [83609.679993] btrfs-transacti(726): WRITE block
78530816 on dm-3 (8 sectors) [83609.679997] btrfs-submit-1(693): WRITE
block 134411768 on dm-3 (480 sectors) [83609.680004]
btrfs-transacti(726): WRITE block 78268752 on dm-3 (16 sectors)
[83609.680011] btrfs-transacti(726): WRITE block 78530896 on dm-3 (16
sectors) [83609.680032] btrfs-transacti(726): WRITE block 78268776 on
dm-3 (24 sectors) [83609.680037] btrfs-transacti(726): WRITE block
78530920 on dm-3 (24 sectors) [83609.680047] btrfs-transacti(726):
WRITE block 78268800 on dm-3 (8 sectors) [83609.680053]
btrfs-transacti(726): WRITE block 78530944 on dm-3 (8 sectors)
[83609.680073] btrfs-transacti(726): WRITE block 78268816 on dm-3 (16
sectors) [83609.680078] btrfs-transacti(726): WRITE block 78530960 on
dm-3 (16 sectors) [83609.680090] btrfs-transacti(726): WRITE block
78268840 on dm-3 (16 sectors) [83609.680097] btrfs-transacti(726):
WRITE block 78530984 on dm-3 (16 sectors) [83609.680109]
btrfs-transacti(726): WRITE block 78268864 on dm-3 (16 sectors)
[83609.680113] btrfs-transacti(726): WRITE block 78531008 on dm-3 (16
sectors) [83609.680130] btrfs-transacti(726): WRITE block 78268888 on
dm-3 (8 sectors) [83609.680135] btrfs-transacti(726): WRITE block
78531032 on dm-3 (8 sectors) [83609.680149] btrfs-transacti(726):
WRITE block 78268920 on dm-3 (8 sectors) [83609.680153]
btrfs-transacti(726): WRITE block 78531064 on dm-3 (8 sectors)
[83609.680170] btrfs-transacti(726): WRITE block 78268928 on dm-3 (40
sectors) [83609.680176] btrfs-transacti(726): WRITE block 78531072 on
dm-3 (40 sectors) [83609.680203] btrfs-transacti(726): WRITE block
78268984 on dm-3 (72 sectors) [83609.680208] btrfs-transacti(726):
WRITE block 78531128 on dm-3 (72 sectors) [83609.680233]
btrfs-transacti(726): WRITE block 78269056 on dm-3 (64 sectors)
[83609.680237] btrfs-transacti(726): WRITE block 78531200 on dm-3 (64
sectors) [83609.680262] btrfs-transacti(726): WRITE block 78269200 on
dm-3 (56 sectors) [83609.680267] btrfs-transacti(726): WRITE block
78531344 on dm-3 (56 sectors) [83609.680307] btrfs-transacti(726):
WRITE block 78269320 on dm-3 (120 sectors) [83609.680317]
btrfs-transacti(726): WRITE block 78531464 on dm-3 (120 sectors)
[83609.680332] btrfs-transacti(726): WRITE block 78269440 on dm-3 (32
sectors) [83609.680337] btrfs-transacti(726): WRITE block 78531584 on
dm-3 (32 sectors) [83609.680352] btrfs-transacti(726): WRITE block
78269480 on dm-3 (24 sectors) [83609.680355] btrfs-transacti(726):
WRITE block 78531624 on dm-3 (24 sectors) [83609.680371]
btrfs-transacti(726): WRITE block 78269512 on dm-3 (56 sectors)
[83609.680375] btrfs-transacti(726): WRITE block 78531656 on dm-3 (56
sectors) [83609.680392] btrfs-transacti(726): WRITE block 78269568 on
dm-3 (72 sectors) [83609.680396] btrfs-transacti(726): WRITE block
78531712 on dm-3 (72 sectors) [83609.680409] btrfs-transacti(726):
WRITE block 78269648 on dm-3 (32 sectors) [83609.680412]
btrfs-transacti(726): WRITE block 78531792 on dm-3 (32 sectors)
[83609.680422] btrfs-transacti(726): WRITE block 78269688 on dm-3 (8
sectors) [83609.680425] btrfs-transacti(726): WRITE block 78531832 on
dm-3 (8 sectors) [83609.680454] btrfs-transacti(726): WRITE block
78269696 on dm-3 (128 sectors) [83609.680457] btrfs-transacti(726):
WRITE block 78531840 on dm-3 (128 sectors) [83609.680486]
btrfs-transacti(726): WRITE block 78269824 on dm-3 (128 sectors)
[83609.680491] btrfs-transacti(726): WRITE block 78531968 on dm-3 (128
sectors) [83609.680498] btrfs-transacti(726): WRITE block 78269952 on
dm-3 (8 sectors) [83609.680501] btrfs-transacti(726): WRITE block
78532096 on dm-3 (8 sectors) [83609.680526] btrfs-transacti(726):
WRITE block 78269968 on dm-3 (104 sectors) [83609.680529]
btrfs-transacti(726): WRITE block 78532112 on dm-3 (104 sectors)
[83609.680559] btrfs-transacti(726): WRITE block 78270080 on dm-3 (128
sectors) [83609.680562] btrfs-transacti(726): WRITE block 78532224 on
dm-3 (128 sectors) [83609.680570] btrfs-transacti(726): WRITE block
78270208 on dm-3 (16 sectors) [83609.680574] btrfs-transacti(726):
WRITE block 78532352 on dm-3 (16 sectors) [83609.680582]
btrfs-transacti(726): WRITE block 78270232 on dm-3 (8 sectors)
[83609.680585] btrfs-transacti(726): WRITE block 78532376 on dm-3 (8
sectors) [83609.680608] btrfs-transacti(726): WRITE block 78270248 on
dm-3 (88 sectors) [83609.680611] btrfs-transacti(726): WRITE block
78532392 on dm-3 (88 sectors) [83609.680639] btrfs-transacti(726):
WRITE block 78270336 on dm-3 (120 sectors) [83609.680642]
btrfs-transacti(726): WRITE block 78532480 on dm-3 (120 sectors)
[83609.680656] btrfs-transacti(726): WRITE block 78270464 on dm-3 (24
sectors) [83609.680664] btrfs-transacti(726): WRITE block 78532608 on
dm-3 (24 sectors) [83609.680688] btrfs-transacti(726): WRITE block
78270496 on dm-3 (96 sectors) [83609.680692] btrfs-transacti(726):
WRITE block 78532640 on dm-3 (96 sectors) [83609.680735]
btrfs-transacti(726): WRITE block 78270600 on dm-3 (120 sectors)
[83609.680739] btrfs-transacti(726): WRITE block 78532744 on dm-3 (120
sectors) [83609.680750] btrfs-transacti(726): WRITE block 78270720 on
dm-3 (24 sectors) [83609.680753] btrfs-transacti(726): WRITE block
78532864 on dm-3 (24 sectors) [83609.680778] btrfs-transacti(726):
WRITE block 78270752 on dm-3 (96 sectors) [83609.680782]
btrfs-transacti(726): WRITE block 78532896 on dm-3 (96 sectors)
[83609.680800] btrfs-transacti(726): WRITE block 78270848 on dm-3 (80
sectors) [83609.680804] btrfs-transacti(726): WRITE block 78532992 on
dm-3 (80 sectors) [83609.680819] btrfs-transacti(726): WRITE block
78270936 on dm-3 (40 sectors) [83609.680822] btrfs-transacti(726):
WRITE block 78533080 on dm-3 (40 sectors) [83609.680846]
btrfs-transacti(726): WRITE block 78270976 on dm-3 (96 sectors)
[83609.680849] btrfs-transacti(726): WRITE block 78533120 on dm-3 (96
sectors) [83609.680859] btrfs-transacti(726): WRITE block 78271088 on
dm-3 (16 sectors) [83609.680863] btrfs-transacti(726): WRITE block
78533232 on dm-3 (16 sectors) [83609.680889] btrfs-transacti(726):
WRITE block 78271104 on dm-3 (120 sectors) [83609.680893]
btrfs-transacti(726): WRITE block 78533248 on dm-3 (120 sectors)
[83609.680924] btrfs-transacti(726): WRITE block 78271240 on dm-3 (120
sectors) [83609.680927] btrfs-transacti(726): WRITE block 78533384 on
dm-3 (120 sectors) [83609.680951] btrfs-transacti(726): WRITE block
78271360 on dm-3 (104 sectors) [83609.680954] btrfs-transacti(726):
WRITE block 78533504 on dm-3 (104 sectors) [83609.680966]
btrfs-transacti(726): WRITE block 78271472 on dm-3 (16 sectors)
[83609.680970] btrfs-transacti(726): WRITE block 78533616 on dm-3 (16
sectors) [83609.680998] btrfs-transacti(726): WRITE block 78271488 on
dm-3 (128 sectors) [83609.681002] btrfs-transacti(726): WRITE block
78533632 on dm-3 (128 sectors) [83609.681014] btrfs-transacti(726):
WRITE block 78271616 on dm-3 (40 sectors) [83609.681017]
btrfs-transacti(726): WRITE block 78533760 on dm-3 (40 sectors)
[83609.681026] btrfs-transacti(726): WRITE block 78271672 on dm-3 (8
sectors) [83609.681029] btrfs-transacti(726): WRITE block 78533816 on
dm-3 (8 sectors) [83609.681047] btrfs-transacti(726): WRITE block
78271688 on dm-3 (56 sectors) [83609.681051] btrfs-transacti(726):
WRITE block 78533832 on dm-3 (56 sectors) [83609.681067]
btrfs-transacti(726): WRITE block 78271744 on dm-3 (32 sectors)
[83609.681071] btrfs-transacti(726): WRITE block 78533888 on dm-3 (32
sectors) [83609.681082] btrfs-transacti(726): WRITE block 78271784 on
dm-3 (32 sectors) [83609.681086] btrfs-transacti(726): WRITE block
78533928 on dm-3 (32 sectors) [83609.681102] btrfs-transacti(726):
WRITE block 78271824 on dm-3 (48 sectors) [83609.681105]
btrfs-transacti(726): WRITE block 78533968 on dm-3 (48 sectors)
[83609.681131] btrfs-transacti(726): WRITE block 78271872 on dm-3 (96
sectors) [83609.681134] btrfs-transacti(726): WRITE block 78534016 on
dm-3 (96 sectors) [83609.681147] btrfs-transacti(726): WRITE block
78271976 on dm-3 (24 sectors) [83609.681150] btrfs-transacti(726):
WRITE block 78534120 on dm-3 (24 sectors) [83609.681177]
btrfs-transacti(726): WRITE block 78272000 on dm-3 (120 sectors)
[83609.681180] btrfs-transacti(726): WRITE block 78534144 on dm-3 (120
sectors) [83609.681188] btrfs-transacti(726): WRITE block 78272136 on
dm-3 (8 sectors) [83609.681191] btrfs-transacti(726): WRITE block
78534280 on dm-3 (8 sectors) [83609.681202] btrfs-transacti(726):
WRITE block 78272152 on dm-3 (24 sectors) [83609.681206]
btrfs-transacti(726): WRITE block 78534296 on dm-3 (24 sectors)
[83609.681215] btrfs-transacti(726): WRITE block 78272184 on dm-3 (8
sectors) [83609.681223] btrfs-transacti(726): WRITE block 78534328 on
dm-3 (8 sectors) [83609.681238] btrfs-transacti(726): WRITE block
78272200 on dm-3 (48 sectors) [83609.681241] btrfs-transacti(726):
WRITE block 78534344 on dm-3 (48 sectors) [83609.681261]
btrfs-transacti(726): WRITE block 78272256 on dm-3 (72 sectors)
[83609.681264] btrfs-transacti(726): WRITE block 78534400 on dm-3 (72
sectors) [83609.681281] btrfs-transacti(726): WRITE block 78272336 on
dm-3 (48 sectors) [83609.681284] btrfs-transacti(726): WRITE block
78534480 on dm-3 (48 sectors) [83609.681312] btrfs-transacti(726):
WRITE block 78272384 on dm-3 (128 sectors) [83609.681316]
btrfs-transacti(726): WRITE block 78534528 on dm-3 (128 sectors)
[83609.681323] btrfs-submit-1(693): WRITE block 134792744 on dm-3 (680
sectors) [83609.681330] btrfs-submit-1(693): WRITE block 134793424 on
dm-3 (824 sectors) [83609.681334] btrfs-submit-1(693): WRITE block
136092600 on dm-3 (1024 sectors) [83609.681337] btrfs-submit-1(693):
WRITE block 136093624 on dm-3 (472 sectors) [83609.681340]
btrfs-submit-1(693): WRITE block 136386184 on dm-3 (1024 sectors)
[83609.681343] btrfs-submit-1(693): WRITE block 136387208 on dm-3 (472
sectors) [83609.681344] btrfs-transacti(726): WRITE block 78272512 on
dm-3 (128 sectors) [83609.681347] btrfs-transacti(726): WRITE block
78534656 on dm-3 (128 sectors) [83609.681351] btrfs-submit-1(693):
WRITE block 136485136 on dm-3 (1024 sectors) [83609.681354]
btrfs-submit-1(693): WRITE block 136486160 on dm-3 (472 sectors)
[83609.681356] btrfs-submit-1(693): WRITE block 140550840 on dm-3
(1024 sectors) [83609.681359] btrfs-submit-1(693): WRITE block
140551864 on dm-3 (472 sectors) [83609.681364] btrfs-submit-1(693):
WRITE block 141093400 on dm-3 (1024 sectors) [83609.681366]
btrfs-submit-1(693): WRITE block 141094424 on dm-3 (472 sectors)
[83609.681369] btrfs-submit-1(693): WRITE block 141590664 on dm-3
(1024 sectors) [83609.681371] btrfs-submit-1(693): WRITE block
141591688 on dm-3 (472 sectors) [83609.681374] btrfs-submit-1(693):
WRITE block 142354384 on dm-3 (1024 sectors) [83609.681378]
btrfs-submit-1(693): WRITE block 142355408 on dm-3 (464 sectors)
[83609.681379] btrfs-transacti(726): WRITE block 78272640 on dm-3 (128
sectors) [83609.681381] btrfs-submit-1(693): WRITE block 144187792 on
dm-3 (1024 sectors) [83609.681383] btrfs-transacti(726): WRITE block
78534784 on dm-3 (128 sectors) [83609.681384] btrfs-submit-1(693):
WRITE block 144188816 on dm-3 (464 sectors) [83609.681387]
btrfs-submit-1(693): WRITE block 144767480 on dm-3 (1024 sectors)
[83609.681389] btrfs-submit-1(693): WRITE block 144768504 on dm-3 (464
sectors) [83609.681392] btrfs-submit-1(693): WRITE block 144808256 on
dm-3 (1024 sectors) [83609.681394] btrfs-submit-1(693): WRITE block
144809280 on dm-3 (464 sectors) [83609.681397] btrfs-submit-1(693):
WRITE block 144845696 on dm-3 (712 sectors) [83609.681399]
btrfs-submit-1(693): WRITE block 144846408 on dm-3 (776 sectors)
[83609.681407] btrfs-transacti(726): WRITE block 78272768 on dm-3 (88
sectors) [83609.681413] btrfs-transacti(726): WRITE block 78534912 on
dm-3 (88 sectors) [83609.681421] btrfs-transacti(726): WRITE block
78272864 on dm-3 (8 sectors) [83609.681424] btrfs-transacti(726):
WRITE block 78535008 on dm-3 (8 sectors) [83609.681433]
btrfs-transacti(726): WRITE block 78272880 on dm-3 (16 sectors)
[83609.681436] btrfs-transacti(726): WRITE block 78535024 on dm-3 (16
sectors) [83609.681453] btrfs-submit-1(693): WRITE block 144857736 on
dm-3 (1024 sectors) [83609.681458] btrfs-transacti(726): WRITE block
78272904 on dm-3 (80 sectors) [83609.681461] btrfs-transacti(726):
WRITE block 78535048 on dm-3 (80 sectors) [83609.681474]
btrfs-transacti(726): WRITE block 78272992 on dm-3 (32 sectors)
[83609.681477] btrfs-transacti(726): WRITE block 78535136 on dm-3 (32
sectors) [83609.681485] btrfs-transacti(726): WRITE block 78273024 on
dm-3 (16 sectors) [83609.681488] btrfs-transacti(726): WRITE block
78535168 on dm-3 (16 sectors) [83609.681513] btrfs-transacti(726):
WRITE block 78273056 on dm-3 (96 sectors) [83609.681517]
btrfs-transacti(726): WRITE block 78535200 on dm-3 (96 sectors)
[83609.681540] btrfs-transacti(726): WRITE block 78273152 on dm-3 (96
sectors) [83609.681543] btrfs-transacti(726): WRITE block 78535296 on
dm-3 (96 sectors) [83609.681559] btrfs-transacti(726): WRITE block
78273256 on dm-3 (24 sectors) [83609.681564] btrfs-transacti(726):
WRITE block 78535400 on dm-3 (24 sectors) [83609.681592]
btrfs-transacti(726): WRITE block 78273280 on dm-3 (128 sectors)
[83609.681596] btrfs-transacti(726): WRITE block 78535424 on dm-3 (128
sectors) [83609.681617] btrfs-transacti(726): WRITE block 78273408 on
dm-3 (80 sectors) [83609.681620] btrfs-transacti(726): WRITE block
78535552 on dm-3 (80 sectors) [83609.681633] btrfs-transacti(726):
WRITE block 78273496 on dm-3 (40 sectors) [83609.681636]
btrfs-transacti(726): WRITE block 78535640 on dm-3 (40 sectors)
[83609.681665] btrfs-transacti(726): WRITE block 78273536 on dm-3 (128
sectors) [83609.681668] btrfs-transacti(726): WRITE block 78535680 on
dm-3 (128 sectors) [83609.681679] btrfs-transacti(726): WRITE block
78273664 on dm-3 (32 sectors) [83609.681683] btrfs-transacti(726):
WRITE block 78535808 on dm-3 (32 sectors) [83609.681694]
btrfs-transacti(726): WRITE block 78273768 on dm-3 (24 sectors)
[83609.681698] btrfs-transacti(726): WRITE block 78535912 on dm-3 (24
sectors) [83609.681725] btrfs-transacti(726): WRITE block 78273792 on
dm-3 (112 sectors) [83609.681728] btrfs-transacti(726): WRITE block
78535936 on dm-3 (112 sectors) [83609.681739] btrfs-transacti(726):
WRITE block 78273920 on dm-3 (16 sectors) [83609.681743]
btrfs-transacti(726): WRITE block 78536064 on dm-3 (16 sectors)
[83609.681753] btrfs-transacti(726): WRITE block 78273944 on dm-3 (24
sectors) [83609.681757] btrfs-transacti(726): WRITE block 78536088 on
dm-3 (24 sectors) [83609.681768] btrfs-transacti(726): WRITE block
78273976 on dm-3 (24 sectors) [83609.681771] btrfs-transacti(726):
WRITE block 78536120 on dm-3 (24 sectors) [83609.681787]
btrfs-transacti(726): WRITE block 78274008 on dm-3 (40 sectors)
[83609.681790] btrfs-transacti(726): WRITE block 78536152 on dm-3 (40
sectors) [83609.681831] btrfs-transacti(726): WRITE block 78274048 on
dm-3 (128 sectors) [83609.681837] btrfs-transacti(726): WRITE block
78536192 on dm-3 (128 sectors) [83609.681875] btrfs-transacti(726):
WRITE block 78274176 on dm-3 (128 sectors) [83609.681879]
btrfs-transacti(726): WRITE block 78536320 on dm-3 (128 sectors)
[83609.681908] btrfs-transacti(726): WRITE block 78274304 on dm-3 (128
sectors) [83609.681912] btrfs-transacti(726): WRITE block 78536448 on
dm-3 (128 sectors) [83609.681922] btrfs-transacti(726): WRITE block
78274432 on dm-3 (24 sectors) [83609.681925] btrfs-transacti(726):
WRITE block 78536576 on dm-3 (24 sectors) [83609.681939]
btrfs-transacti(726): WRITE block 78274464 on dm-3 (40 sectors)
[83609.681944] btrfs-transacti(726): WRITE block 78536608 on dm-3 (40
sectors) [83609.681961] btrfs-transacti(726): WRITE block 78274512 on
dm-3 (48 sectors) [83609.681964] btrfs-transacti(726): WRITE block
78536656 on dm-3 (48 sectors) [83609.681992] btrfs-transacti(726):
WRITE block 78274560 on dm-3 (128 sectors) [83609.682000]
btrfs-transacti(726): WRITE block 78536704 on dm-3 (128 sectors)
[83609.682018] btrfs-transacti(726): WRITE block 78274688 on dm-3 (72
sectors) [83609.682021] btrfs-transacti(726): WRITE block 78536832 on
dm-3 (72 sectors) [83609.682029] btrfs-transacti(726): WRITE block
78274768 on dm-3 (8 sectors) [83609.682032] btrfs-transacti(726):
WRITE block 78536912 on dm-3 (8 sectors) [83609.682044]
btrfs-transacti(726): WRITE block 78274792 on dm-3 (24 sectors)
[83609.682047] btrfs-transacti(726): WRITE block 78536936 on dm-3 (24
sectors) [83609.682083] btrfs-transacti(726): WRITE block 78274816 on
dm-3 (88 sectors) [83609.682089] btrfs-transacti(726): WRITE block
78536960 on dm-3 (88 sectors) [83609.682094] btrfs-submit-1(693):
WRITE block 144858760 on dm-3 (456 sectors) [83609.682101]
btrfs-transacti(726): WRITE block 78274912 on dm-3 (8 sectors)
[83609.682103] btrfs-submit-1(693): WRITE block 145147040 on dm-3
(1024 sectors) [83609.682105] btrfs-transacti(726): WRITE block
78537056 on dm-3 (8 sectors) [83609.682108] btrfs-submit-1(693): WRITE
block 145148064 on dm-3 (456 sectors) [83609.682114]
btrfs-submit-1(693): WRITE block 147388952 on dm-3 (1024 sectors)
[83609.682118] btrfs-submit-1(693): WRITE block 147389976 on dm-3 (456
sectors) [83609.682121] btrfs-transacti(726): WRITE block 78274928 on
dm-3 (16 sectors) [83609.682122] btrfs-submit-1(693): WRITE block
166069520 on dm-3 (1024 sectors) [83609.682125] btrfs-submit-1(693):
WRITE block 166070544 on dm-3 (456 sectors) [83609.682126]
btrfs-transacti(726): WRITE block 78537072 on dm-3 (16 sectors)
[83609.682130] btrfs-submit-1(693): WRITE block 169515288 on dm-3
(1024 sectors) [83609.682134] btrfs-submit-1(693): WRITE block
169516312 on dm-3 (456 sectors) [83609.682138] btrfs-submit-1(693):
WRITE block 170322024 on dm-3 (1024 sectors) [83609.682141]
btrfs-submit-1(693): WRITE block 170323048 on dm-3 (456 sectors)
[83609.682157] btrfs-transacti(726): WRITE block 78274944 on dm-3 (128
sectors) [83609.682160] btrfs-transacti(726): WRITE block 78537088 on
dm-3 (128 sectors) [83609.682187] btrfs-transacti(726): WRITE block
78275072 on dm-3 (128 sectors) [83609.682192] btrfs-transacti(726):
WRITE block 78537216 on dm-3 (128 sectors) [83609.682219]
btrfs-transacti(726): WRITE block 78275200 on dm-3 (128 sectors)
[83609.682222] btrfs-transacti(726): WRITE block 78537344 on dm-3 (128
sectors) [83609.682242] btrfs-transacti(726): WRITE block 78275328 on
dm-3 (72 sectors) [83609.682245] btrfs-transacti(726): WRITE block
78537472 on dm-3 (72 sectors) [83609.682259] btrfs-transacti(726):
WRITE block 78275408 on dm-3 (40 sectors) [83609.682262]
btrfs-transacti(726): WRITE block 78537552 on dm-3 (40 sectors)
[83609.682271] btrfs-transacti(726): WRITE block 78275456 on dm-3 (16
sectors) [83609.682275] btrfs-transacti(726): WRITE block 78537600 on
dm-3 (16 sectors) [83609.682300] btrfs-transacti(726): WRITE block
78275480 on dm-3 (104 sectors) [83609.682303] btrfs-transacti(726):
WRITE block 78537624 on dm-3 (104 sectors) [83609.682311]
btrfs-transacti(726): WRITE block 78275584 on dm-3 (8 sectors)
[83609.682315] btrfs-transacti(726): WRITE block 78537728 on dm-3 (8
sectors) [83609.682348] btrfs-transacti(726): WRITE block 78275600 on
dm-3 (112 sectors) [83609.682351] btrfs-transacti(726): WRITE block
78537744 on dm-3 (112 sectors) [83609.682365] btrfs-transacti(726):
WRITE block 78275712 on dm-3 (56 sectors) [83609.682369]
btrfs-transacti(726): WRITE block 78537856 on dm-3 (56 sectors)
[83609.682387] btrfs-transacti(726): WRITE block 78275776 on dm-3 (64
sectors) [83609.682390] btrfs-transacti(726): WRITE block 78537920 on
dm-3 (64 sectors) [83609.682414] btrfs-transacti(726): WRITE block
78275840 on dm-3 (80 sectors) [83609.682419] btrfs-transacti(726):
WRITE block 78537984 on dm-3 (80 sectors) [83609.682433]
btrfs-transacti(726): WRITE block 78275928 on dm-3 (32 sectors)
[83609.682436] btrfs-transacti(726): WRITE block 78538072 on dm-3 (32
sectors) [83609.682467] btrfs-transacti(726): WRITE block 78275968 on
dm-3 (128 sectors) [83609.682471] btrfs-transacti(726): WRITE block
78538112 on dm-3 (128 sectors) [83609.682500] btrfs-transacti(726):
WRITE block 78276096 on dm-3 (128 sectors) [83609.682503]
btrfs-transacti(726): WRITE block 78538240 on dm-3 (128 sectors)
[83609.682532] btrfs-transacti(726): WRITE block 78276224 on dm-3 (128
sectors) [83609.682536] btrfs-transacti(726): WRITE block 78538368 on
dm-3 (128 sectors) [83609.682565] btrfs-transacti(726): WRITE block
78276352 on dm-3 (128 sectors) [83609.682568] btrfs-transacti(726):
WRITE block 78538496 on dm-3 (128 sectors) [83609.682596]
btrfs-transacti(726): WRITE block 78276480 on dm-3 (128 sectors)
[83609.682604] btrfs-transacti(726): WRITE block 78538624 on dm-3 (128
sectors) [83609.682634] btrfs-transacti(726): WRITE block 78276608 on
dm-3 (128 sectors) [83609.682638] btrfs-transacti(726): WRITE block
78538752 on dm-3 (128 sectors) [83609.682659] btrfs-transacti(726):
WRITE block 78276736 on dm-3 (40 sectors) [83609.682663]
btrfs-transacti(726): WRITE block 78538880 on dm-3 (40 sectors)
[83609.682681] btrfs-transacti(726): WRITE block 78276784 on dm-3 (32
sectors) [83609.682686] btrfs-transacti(726): WRITE block 78538928 on
dm-3 (32 sectors) [83609.682701] btrfs-transacti(726): WRITE block
78276824 on dm-3 (40 sectors) [83609.682704] btrfs-transacti(726):
WRITE block 78538968 on dm-3 (40 sectors) [83609.682711]
btrfs-transacti(726): WRITE block 78276864 on dm-3 (8 sectors)
[83609.682714] btrfs-transacti(726): WRITE block 78539008 on dm-3 (8
sectors) [83609.682740] btrfs-transacti(726): WRITE block 78276888 on
dm-3 (104 sectors) [83609.682745] btrfs-transacti(726): WRITE block
78539032 on dm-3 (104 sectors) [83609.682764] btrfs-transacti(726):
WRITE block 78276992 on dm-3 (80 sectors) [83609.682770]
btrfs-transacti(726): WRITE block 78539136 on dm-3 (80 sectors)
[83609.682785] btrfs-transacti(726): WRITE block 78277080 on dm-3 (40
sectors) [83609.682788] btrfs-transacti(726): WRITE block 78539224 on
dm-3 (40 sectors) [83609.682812] btrfs-transacti(726): WRITE block
78277120 on dm-3 (88 sectors) [83609.682815] btrfs-transacti(726):
WRITE block 78539264 on dm-3 (88 sectors) [83609.682827]
btrfs-transacti(726): WRITE block 78277216 on dm-3 (8 sectors)
[83609.682830] btrfs-transacti(726): WRITE block 78539360 on dm-3 (8
sectors) [83609.682840] btrfs-transacti(726): WRITE block 78277232 on
dm-3 (16 sectors) [83609.682844] btrfs-transacti(726): WRITE block
78539376 on dm-3 (16 sectors) [83609.682873] btrfs-transacti(726):
WRITE block 78277248 on dm-3 (128 sectors) [83609.682876]
btrfs-transacti(726): WRITE block 78539392 on dm-3 (128 sectors)
[83609.682894] btrfs-transacti(726): WRITE block 78277376 on dm-3 (64
sectors) [83609.682897] btrfs-transacti(726): WRITE block 78539520 on
dm-3 (64 sectors) [83609.682909] btrfs-transacti(726): WRITE block
78277448 on dm-3 (8 sectors) [83609.682913] btrfs-transacti(726):
WRITE block 78539592 on dm-3 (8 sectors) [83609.682927]
btrfs-transacti(726): WRITE block 78277464 on dm-3 (40 sectors)
[83609.682931] btrfs-transacti(726): WRITE block 78539608 on dm-3 (40
sectors) [83609.682944] btrfs-transacti(726): WRITE block 78277504 on
dm-3 (48 sectors) [83609.682947] btrfs-transacti(726): WRITE block
78539648 on dm-3 (48 sectors) [83609.682959] btrfs-transacti(726):
WRITE block 78277560 on dm-3 (32 sectors) [83609.682962]
btrfs-transacti(726): WRITE block 78539704 on dm-3 (32 sectors)
[83609.682976] btrfs-transacti(726): WRITE block 78277600 on dm-3 (32
sectors) [83609.682979] btrfs-transacti(726): WRITE block 78539744 on
dm-3 (32 sectors) [83609.683008] btrfs-transacti(726): WRITE block
78277632 on dm-3 (128 sectors) [83609.683012] btrfs-transacti(726):
WRITE block 78539776 on dm-3 (128 sectors) [83609.683027]
btrfs-transacti(726): WRITE block 78277760 on dm-3 (48 sectors)
[83609.683030] btrfs-transacti(726): WRITE block 78539904 on dm-3 (48
sectors) [83609.683043] btrfs-transacti(726): WRITE block 78277816 on
dm-3 (32 sectors) [83609.683047] btrfs-transacti(726): WRITE block
78539960 on dm-3 (32 sectors) [83609.683066] btrfs-transacti(726):
WRITE block 78277856 on dm-3 (32 sectors) [83609.683072]
btrfs-transacti(726): WRITE block 78540000 on dm-3 (32 sectors)
[83609.683085] btrfs-transacti(726): WRITE block 78277888 on dm-3 (24
sectors) [83609.683094] btrfs-transacti(726): WRITE block 78540032 on
dm-3 (24 sectors) [83609.683121] btrfs-submit-1(693): WRITE block
171095784 on dm-3 (1024 sectors) [83609.683126] btrfs-transacti(726):
WRITE block 78277920 on dm-3 (96 sectors) [83609.683130]
btrfs-submit-1(693): WRITE block 171096808 on dm-3 (448 sectors)
[83609.683130] btrfs-transacti(726): WRITE block 78540064 on dm-3 (96
sectors) [83609.683137] btrfs-submit-1(693): WRITE block 174268112 on
dm-3 (1024 sectors) [83609.683141] btrfs-submit-1(693): WRITE block
174269136 on dm-3 (448 sectors) [83609.683145] btrfs-submit-1(693):
WRITE block 175856632 on dm-3 (1024 sectors) [83609.683147]
btrfs-transacti(726): WRITE block 78278016 on dm-3 (56 sectors)
[83609.683149] btrfs-submit-1(693): WRITE block 175857656 on dm-3 (448
sectors) [83609.683151] btrfs-transacti(726): WRITE block 78540160 on
dm-3 (56 sectors) [83609.683158] btrfs-submit-1(693): WRITE block
183302176 on dm-3 (1024 sectors) [83609.683162] btrfs-submit-1(693):
WRITE block 183303200 on dm-3 (448 sectors) [83609.683168]
btrfs-transacti(726): WRITE block 78278080 on dm-3 (48 sectors)
[83609.683169] btrfs-submit-1(693): WRITE block 183724832 on dm-3 (920
sectors) [83609.683172] btrfs-submit-1(693): WRITE block 183725752 on
dm-3 (552 sectors) [83609.683173] btrfs-transacti(726): WRITE block
78540224 on dm-3 (48 sectors) [83609.683181] btrfs-submit-1(693):
WRITE block 184076168 on dm-3 (1024 sectors) [83609.683183]
btrfs-transacti(726): WRITE block 78278144 on dm-3 (24 sectors)
[83609.683187] btrfs-submit-1(693): WRITE block 184077192 on dm-3 (440
sectors) [83609.683187] btrfs-transacti(726): WRITE block 78540288 on
dm-3 (24 sectors) [83609.683192] btrfs-submit-1(693): WRITE block
187486320 on dm-3 (1024 sectors) [83609.683195] btrfs-transacti(726):
WRITE block 78278224 on dm-3 (8 sectors) [83609.683197]
btrfs-submit-1(693): WRITE block 187487344 on dm-3 (440 sectors)
[83609.683198] btrfs-transacti(726): WRITE block 78540368 on dm-3 (8
sectors) [83609.683203] btrfs-submit-1(693): WRITE block 190202896 on
dm-3 (1024 sectors) [83609.683206] btrfs-transacti(726): WRITE block
78278240 on dm-3 (8 sectors) [83609.683209] btrfs-transacti(726):
WRITE block 78540384 on dm-3 (8 sectors) [83609.683235]
btrfs-transacti(726): WRITE block 78278272 on dm-3 (88 sectors)
[83609.683242] btrfs-transacti(726): WRITE block 78540416 on dm-3 (88
sectors) [83609.683255] btrfs-transacti(726): WRITE block 78278368 on
dm-3 (32 sectors) [83609.683256] btrfs-submit-1(693): WRITE block
190203920 on dm-3 (440 sectors) [83609.683259] btrfs-transacti(726):
WRITE block 78540512 on dm-3 (32 sectors) [83609.683268]
btrfs-transacti(726): WRITE block 78278400 on dm-3 (24 sectors)
[83609.683271] btrfs-transacti(726): WRITE block 78540544 on dm-3 (24
sectors) [83609.683294] btrfs-transacti(726): WRITE block 78278432 on
dm-3 (88 sectors) [83609.683298] btrfs-transacti(726): WRITE block
78540576 on dm-3 (88 sectors) [83609.683317] btrfs-transacti(726):
WRITE block 78278528 on dm-3 (48 sectors) [83609.683320]
btrfs-transacti(726): WRITE block 78540672 on dm-3 (48 sectors)
[83609.683339] btrfs-transacti(726): WRITE block 78278584 on dm-3 (72
sectors) [83609.683343] btrfs-transacti(726): WRITE block 78540728 on
dm-3 (72 sectors) [83609.683350] btrfs-submit-1(693): WRITE block
190259032 on dm-3 (1024 sectors) [83609.683359] btrfs-transacti(726):
WRITE block 78278672 on dm-3 (56 sectors) [83609.683362]
btrfs-transacti(726): WRITE block 78540816 on dm-3 (56 sectors)
[83609.683373] btrfs-transacti(726): WRITE block 78278736 on dm-3 (24
sectors) [83609.683376] btrfs-transacti(726): WRITE block 78540880 on
dm-3 (24 sectors) [83609.683385] btrfs-transacti(726): WRITE block
78278776 on dm-3 (8 sectors) [83609.683389] btrfs-transacti(726):
WRITE block 78540920 on dm-3 (8 sectors) [83609.683398]
btrfs-submit-1(693): WRITE block 190260056 on dm-3 (440 sectors)
[83609.683411] btrfs-transacti(726): WRITE block 78278784 on dm-3 (96
sectors) [83609.683418] btrfs-transacti(726): WRITE block 78540928 on
dm-3 (96 sectors) [83609.683430] btrfs-transacti(726): WRITE block
78278888 on dm-3 (24 sectors) [83609.683433] btrfs-transacti(726):
WRITE block 78541032 on dm-3 (24 sectors) [83609.683460]
btrfs-transacti(726): WRITE block 78278912 on dm-3 (112 sectors)
[83609.683463] btrfs-transacti(726): WRITE block 78541056 on dm-3 (112
sectors) [83609.683476] btrfs-transacti(726): WRITE block 78279032 on
dm-3 (8 sectors) [83609.683479] btrfs-transacti(726): WRITE block
78541176 on dm-3 (8 sectors) [83609.683502] btrfs-submit-1(693): WRITE
block 190270360 on dm-3 (1024 sectors) [83609.683507]
btrfs-transacti(726): WRITE block 78279040 on dm-3 (128 sectors)
[83609.683512] btrfs-transacti(726): WRITE block 78541184 on dm-3 (128
sectors) [83609.683527] btrfs-transacti(726): WRITE block 78279168 on
dm-3 (56 sectors) [83609.683530] btrfs-transacti(726): WRITE block
78541312 on dm-3 (56 sectors) [83609.683551] btrfs-transacti(726):
WRITE block 78279240 on dm-3 (56 sectors) [83609.683552]
btrfs-submit-1(693): WRITE block 190271384 on dm-3 (440 sectors)
[83609.683557] btrfs-transacti(726): WRITE block 78541384 on dm-3 (56
sectors) [83609.683566] btrfs-transacti(726): WRITE block 78279296 on
dm-3 (16 sectors) [83609.683570] btrfs-transacti(726): WRITE block
78541440 on dm-3 (16 sectors) [83609.683578] btrfs-transacti(726):
WRITE block 78279320 on dm-3 (8 sectors) [83609.683582]
btrfs-transacti(726): WRITE block 78541464 on dm-3 (8 sectors)
[83609.683602] btrfs-transacti(726): WRITE block 78279344 on dm-3 (80
sectors) [83609.683605] btrfs-transacti(726): WRITE block 78541488 on
dm-3 (80 sectors) [83609.683627] btrfs-transacti(726): WRITE block
78279424 on dm-3 (72 sectors) [83609.683630] btrfs-transacti(726):
WRITE block 78541568 on dm-3 (72 sectors) [83609.683640]
btrfs-transacti(726): WRITE block 78279504 on dm-3 (16 sectors)
[83609.683643] btrfs-transacti(726): WRITE block 78541648 on dm-3 (16
sectors) [83609.683652] btrfs-transacti(726): WRITE block 78279536 on
dm-3 (16 sectors) [83609.683655] btrfs-submit-1(693): WRITE block
190295304 on dm-3 (1024 sectors) [83609.683660] btrfs-transacti(726):
WRITE block 78541680 on dm-3 (16 sectors) [83609.683684]
btrfs-transacti(726): WRITE block 78279552 on dm-3 (112 sectors)
[83609.683687] btrfs-transacti(726): WRITE block 78541696 on dm-3 (112
sectors) [83609.683702] btrfs-transacti(726): WRITE block 78279808 on
dm-3 (40 sectors) [83609.683705] btrfs-submit-1(693): WRITE block
190296328 on dm-3 (440 sectors) [83609.683706] btrfs-transacti(726):
WRITE block 78541952 on dm-3 (40 sectors) [83609.683715]
btrfs-transacti(726): WRITE block 78279960 on dm-3 (8 sectors)
[83609.683720] btrfs-transacti(726): WRITE block 78542104 on dm-3 (8
sectors) [83609.683743] btrfs-transacti(726): WRITE block 78279976 on
dm-3 (88 sectors) [83609.683747] btrfs-transacti(726): WRITE block
78542120 on dm-3 (88 sectors) [83609.683775] btrfs-transacti(726):
WRITE block 78280064 on dm-3 (128 sectors) [83609.683778]
btrfs-transacti(726): WRITE block 78542208 on dm-3 (128 sectors)
[83609.683808] btrfs-transacti(726): WRITE block 78280192 on dm-3 (128
sectors) [83609.683809] btrfs-submit-1(693): WRITE block 190319232 on
dm-3 (1024 sectors) [83609.683813] btrfs-transacti(726): WRITE block
78542336 on dm-3 (128 sectors) [83609.683843] btrfs-transacti(726):
WRITE block 78280320 on dm-3 (128 sectors) [83609.683846]
btrfs-transacti(726): WRITE block 78542464 on dm-3 (128 sectors)
[83609.683854] btrfs-submit-1(693): WRITE block 190320256 on dm-3 (432
sectors) [83609.683857] btrfs-transacti(726): WRITE block 78280448 on
dm-3 (32 sectors) [83609.683861] btrfs-transacti(726): WRITE block
78542592 on dm-3 (32 sectors) [83609.683870] btrfs-transacti(726):
WRITE block 78280488 on dm-3 (8 sectors) [83609.683873]
btrfs-transacti(726): WRITE block 78542632 on dm-3 (8 sectors)
[83609.683891] btrfs-transacti(726): WRITE block 78280504 on dm-3 (64
sectors) [83609.683894] btrfs-transacti(726): WRITE block 78542648 on
dm-3 (64 sectors) [83609.683926] btrfs-transacti(726): WRITE block
78280576 on dm-3 (128 sectors) [83609.683931] btrfs-transacti(726):
WRITE block 78542720 on dm-3 (128 sectors) [83609.683959]
btrfs-transacti(726): WRITE block 78280704 on dm-3 (128 sectors)
[83609.683964] btrfs-transacti(726): WRITE block 78542848 on dm-3 (128
sectors) [83609.683992] btrfs-transacti(726): WRITE block 78280832 on
dm-3 (128 sectors) [83609.683994] btrfs-submit-1(693): WRITE block
190368856 on dm-3 (1024 sectors) [83609.683995] btrfs-transacti(726):
WRITE block 78542976 on dm-3 (128 sectors) [83609.684026]
btrfs-transacti(726): WRITE block 78280960 on dm-3 (128 sectors)
[83609.684029] btrfs-transacti(726): WRITE block 78543104 on dm-3 (128
sectors) [83609.684040] btrfs-submit-1(693): WRITE block 190369880 on
dm-3 (432 sectors) [83609.684068] btrfs-transacti(726): WRITE block
78281088 on dm-3 (128 sectors) [83609.684072] btrfs-transacti(726):
WRITE block 78543232 on dm-3 (128 sectors) [83609.684094]
btrfs-transacti(726): WRITE block 78281216 on dm-3 (88 sectors)
[83609.684098] btrfs-transacti(726): WRITE block 78543360 on dm-3 (88
sectors) [83609.684111] btrfs-transacti(726): WRITE block 78281312 on
dm-3 (32 sectors) [83609.684114] btrfs-transacti(726): WRITE block
78543456 on dm-3 (32 sectors) [83609.684143] btrfs-transacti(726):
WRITE block 78281344 on dm-3 (128 sectors) [83609.684146]
btrfs-transacti(726): WRITE block 78543488 on dm-3 (128 sectors)
[83609.684153] btrfs-submit-1(693): WRITE block 190371872 on dm-3
(1024 sectors) [83609.684178] btrfs-transacti(726): WRITE block
78281472 on dm-3 (128 sectors) [83609.684183] btrfs-transacti(726):
WRITE block 78543616 on dm-3 (128 sectors) [83609.684193]
btrfs-transacti(726): WRITE block 78281600 on dm-3 (24 sectors)
[83609.684198] btrfs-transacti(726): WRITE block 78543744 on dm-3 (24
sectors) [83609.684201] btrfs-submit-1(693): WRITE block 190372896 on
dm-3 (432 sectors) [83609.684223] btrfs-transacti(726): WRITE block
78281632 on dm-3 (96 sectors) [83609.684226] btrfs-transacti(726):
WRITE block 78543776 on dm-3 (96 sectors) [83609.684236]
btrfs-transacti(726): WRITE block 78281728 on dm-3 (16 sectors)
[83609.684239] btrfs-transacti(726): WRITE block 78543872 on dm-3 (16
sectors) [83609.684249] btrfs-transacti(726): WRITE block 78281752 on
dm-3 (16 sectors) [83609.684252] btrfs-transacti(726): WRITE block
78543896 on dm-3 (16 sectors) [83609.684268] btrfs-transacti(726):
WRITE block 78281776 on dm-3 (48 sectors) [83609.684272]
btrfs-transacti(726): WRITE block 78543920 on dm-3 (48 sectors)
[83609.684281] btrfs-transacti(726): WRITE block 78281832 on dm-3 (16
sectors) [83609.684284] btrfs-transacti(726): WRITE block 78543976 on
dm-3 (16 sectors) [83609.684292] btrfs-transacti(726): WRITE block
78281856 on dm-3 (8 sectors) [83609.684295] btrfs-transacti(726):
WRITE block 78544000 on dm-3 (8 sectors) [83609.684318]
btrfs-submit-1(693): WRITE block 191753352 on dm-3 (1024 sectors)
[83609.684319] btrfs-transacti(726): WRITE block 78281880 on dm-3 (96
sectors) [83609.684324] btrfs-transacti(726): WRITE block 78544024 on
dm-3 (96 sectors) [83609.684343] btrfs-transacti(726): WRITE block
78281984 on dm-3 (72 sectors) [83609.684347] btrfs-transacti(726):
WRITE block 78544128 on dm-3 (72 sectors) [83609.684353]
btrfs-submit-1(693): WRITE block 191754376 on dm-3 (432 sectors)
[83609.684356] btrfs-transacti(726): WRITE block 78282064 on dm-3 (16
sectors) [83609.684359] btrfs-transacti(726): WRITE block 78544208 on
dm-3 (16 sectors) [83609.684371] btrfs-transacti(726): WRITE block
78282088 on dm-3 (24 sectors) [83609.684374] btrfs-transacti(726):
WRITE block 78544232 on dm-3 (24 sectors) [83609.684392]
btrfs-transacti(726): WRITE block 78282120 on dm-3 (56 sectors)
[83609.684395] btrfs-transacti(726): WRITE block 78544264 on dm-3 (56
sectors) [83609.684408] btrfs-transacti(726): WRITE block 78282296 on
dm-3 (40 sectors) [83609.684412] btrfs-transacti(726): WRITE block
78544440 on dm-3 (40 sectors) [83609.684422] btrfs-transacti(726):
WRITE block 78282352 on dm-3 (16 sectors) [83609.684424]
btrfs-transacti(726): WRITE block 78544496 on dm-3 (16 sectors)
[83609.684434] btrfs-transacti(726): WRITE block 78282368 on dm-3 (16
sectors) [83609.684436] btrfs-transacti(726): WRITE block 78544512 on
dm-3 (16 sectors) [83609.684440] btrfs-submit-1(693): WRITE block
199259400 on dm-3 (1024 sectors) [83609.684446] btrfs-transacti(726):
WRITE block 78282392 on dm-3 (8 sectors) [83609.684450]
btrfs-transacti(726): WRITE block 78544536 on dm-3 (8 sectors)
[83609.684464] btrfs-transacti(726): WRITE block 78282408 on dm-3 (48
sectors) [83609.684466] btrfs-submit-1(693): WRITE block 199260424 on
dm-3 (280 sectors) [83609.684470] btrfs-transacti(726): WRITE block
78544552 on dm-3 (48 sectors) [83609.684478] btrfs-transacti(726):
WRITE block 78282472 on dm-3 (8 sectors) [83609.684480]
btrfs-submit-1(693): WRITE block 199260704 on dm-3 (152 sectors)
[83609.684481] btrfs-transacti(726): WRITE block 78544616 on dm-3 (8
sectors) [83609.684489] btrfs-transacti(726): WRITE block 78282488 on
dm-3 (8 sectors) [83609.684492] btrfs-transacti(726): WRITE block
78544632 on dm-3 (8 sectors) [83609.684508] btrfs-transacti(726):
WRITE block 78282512 on dm-3 (48 sectors) [83609.684511]
btrfs-transacti(726): WRITE block 78544656 on dm-3 (48 sectors)
[83609.684528] btrfs-transacti(726): WRITE block 78282568 on dm-3 (56
sectors) [83609.684533] btrfs-transacti(726): WRITE block 78544712 on
dm-3 (56 sectors) [83609.684561] btrfs-transacti(726): WRITE block
78282624 on dm-3 (128 sectors) [83609.684564] btrfs-submit-1(693):
WRITE block 199872792 on dm-3 (1024 sectors) [83609.684565]
btrfs-transacti(726): WRITE block 78544768 on dm-3 (128 sectors)
[83609.684575] btrfs-transacti(726): WRITE block 78282752 on dm-3 (24
sectors) [83609.684578] btrfs-transacti(726): WRITE block 78544896 on
dm-3 (24 sectors) [83609.684587] btrfs-transacti(726): WRITE block
78282792 on dm-3 (8 sectors) [83609.684591] btrfs-transacti(726):
WRITE block 78544936 on dm-3 (8 sectors) [83609.684603]
btrfs-submit-1(693): WRITE block 199873816 on dm-3 (432 sectors)
[83609.684617] btrfs-transacti(726): WRITE block 78282904 on dm-3 (104
sectors) [83609.684622] btrfs-transacti(726): WRITE block 78545048 on
dm-3 (104 sectors) [83609.684651] btrfs-transacti(726): WRITE block
78283008 on dm-3 (128 sectors) [83609.684656] btrfs-transacti(726):
WRITE block 78545152 on dm-3 (128 sectors) [83609.684673]
btrfs-transacti(726): WRITE block 78283136 on dm-3 (64 sectors)
[83609.684676] btrfs-transacti(726): WRITE block 78545280 on dm-3 (64
sectors) [83609.684688] btrfs-submit-1(693): WRITE block 199960328 on
dm-3 (1024 sectors) [83609.684694] btrfs-transacti(726): WRITE block
78283208 on dm-3 (56 sectors) [83609.684697] btrfs-transacti(726):
WRITE block 78545352 on dm-3 (56 sectors) [83609.684726]
btrfs-submit-1(693): WRITE block 199961352 on dm-3 (424 sectors)
[83609.684728] btrfs-transacti(726): WRITE block 78283264 on dm-3 (128
sectors) [83609.684732] btrfs-transacti(726): WRITE block 78545408 on
dm-3 (128 sectors) [83609.684740] btrfs-transacti(726): WRITE block
78283392 on dm-3 (16 sectors) [83609.684743] btrfs-transacti(726):
WRITE block 78545536 on dm-3 (16 sectors) [83609.684751]
btrfs-transacti(726): WRITE block 78283416 on dm-3 (8 sectors)
[83609.684754] btrfs-transacti(726): WRITE block 78545560 on dm-3 (8
sectors) [83609.684772] btrfs-transacti(726): WRITE block 78283432 on
dm-3 (56 sectors) [83609.684776] btrfs-transacti(726): WRITE block
78545576 on dm-3 (56 sectors) [83609.684786] btrfs-transacti(726):
WRITE block 78283760 on dm-3 (16 sectors) [83609.684791]
btrfs-transacti(726): WRITE block 78545904 on dm-3 (16 sectors)
[83609.684797] btrfs-transacti(726): WRITE block 78283776 on dm-3 (8
sectors) [83609.684799] btrfs-transacti(726): WRITE block 78545920 on
dm-3 (8 sectors) [83609.684812] btrfs-transacti(726): WRITE block
78283808 on dm-3 (32 sectors) [83609.684816] btrfs-transacti(726):
WRITE block 78545952 on dm-3 (32 sectors) [83609.684824]
btrfs-transacti(726): WRITE block 78283848 on dm-3 (8 sectors)
[83609.684827] btrfs-transacti(726): WRITE block 78545992 on dm-3 (8
sectors) [83609.684835] btrfs-transacti(726): WRITE block 78283880 on
dm-3 (8 sectors) [83609.684841] btrfs-transacti(726): WRITE block
78546024 on dm-3 (8 sectors) [83609.684844] btrfs-submit-1(693): WRITE
block 200119528 on dm-3 (1024 sectors) [83609.684848]
btrfs-transacti(726): WRITE block 78283944 on dm-3 (8 sectors)
[83609.684851] btrfs-transacti(726): WRITE block 78546088 on dm-3 (8
sectors) [83609.684853] btrfs-submit-1(693): WRITE block 200120552 on
dm-3 (424 sectors) [83609.684860] btrfs-transacti(726): WRITE block
78283984 on dm-3 (8 sectors) [83609.684863] btrfs-transacti(726):
WRITE block 78546128 on dm-3 (8 sectors) [83609.684872]
btrfs-transacti(726): WRITE block 78284024 on dm-3 (8 sectors)
[83609.684876] btrfs-transacti(726): WRITE block 78546168 on dm-3 (8
sectors) [83609.684902] btrfs-transacti(726): WRITE block 78284032 on
dm-3 (120 sectors) [83609.684906] btrfs-transacti(726): WRITE block
78546176 on dm-3 (120 sectors) [83609.684921] btrfs-transacti(726):
WRITE block 78284160 on dm-3 (48 sectors) [83609.684924]
btrfs-transacti(726): WRITE block 78546304 on dm-3 (48 sectors)
[83609.684926] btrfs-submit-1(693): WRITE block 200122640 on dm-3
(1024 sectors) [83609.684936] btrfs-transacti(726): WRITE block
78284216 on dm-3 (24 sectors) [83609.684939] btrfs-transacti(726):
WRITE block 78546360 on dm-3 (24 sectors) [83609.684963]
btrfs-submit-1(693): WRITE block 200123664 on dm-3 (424 sectors)
[83609.684966] btrfs-transacti(726): WRITE block 78284312 on dm-3 (104
sectors) [83609.684969] btrfs-transacti(726): WRITE block 78546456 on
dm-3 (104 sectors) [83609.684990] btrfs-transacti(726): WRITE block
78284416 on dm-3 (88 sectors) [83609.684994] btrfs-transacti(726):
WRITE block 78546560 on dm-3 (88 sectors) [83609.685002]
btrfs-transacti(726): WRITE block 78284608 on dm-3 (8 sectors)
[83609.685004] btrfs-transacti(726): WRITE block 78546752 on dm-3 (8
sectors) [83609.685014] btrfs-transacti(726): WRITE block 78284736 on
dm-3 (8 sectors) [83609.685017] btrfs-transacti(726): WRITE block
78546880 on dm-3 (8 sectors) [83609.685033] btrfs-transacti(726):
WRITE block 78284752 on dm-3 (48 sectors) [83609.685037]
btrfs-transacti(726): WRITE block 78546896 on dm-3 (48 sectors)
[83609.685047] btrfs-submit-1(693): WRITE block 200444440 on dm-3
(1024 sectors) [83609.685075] btrfs-transacti(726): WRITE block
78284800 on dm-3 (128 sectors) [83609.685081] btrfs-transacti(726):
WRITE block 78546944 on dm-3 (128 sectors) [83609.685090]
btrfs-submit-1(693): WRITE block 200445464 on dm-3 (424 sectors)
[83609.685091] btrfs-transacti(726): WRITE block 78284928 on dm-3 (8
sectors) [83609.685094] btrfs-transacti(726): WRITE block 78547072 on
dm-3 (8 sectors) [83609.685109] btrfs-transacti(726): WRITE block
78284944 on dm-3 (16 sectors) [83609.685113] btrfs-transacti(726):
WRITE block 78547088 on dm-3 (16 sectors) [83609.685129]
btrfs-transacti(726): WRITE block 78284968 on dm-3 (16 sectors)
[83609.685132] btrfs-transacti(726): WRITE block 78547112 on dm-3 (16
sectors) [83609.685150] btrfs-transacti(726): WRITE block 78285000 on
dm-3 (56 sectors) [83609.685154] btrfs-transacti(726): WRITE block
78547144 on dm-3 (56 sectors) [83609.685167] btrfs-transacti(726):
WRITE block 78285056 on dm-3 (48 sectors) [83609.685170]
btrfs-transacti(726): WRITE block 78547200 on dm-3 (48 sectors)
[83609.685173] btrfs-submit-1(693): WRITE block 200455992 on dm-3
(1024 sectors) [83609.685189] btrfs-transacti(726): WRITE block
78285232 on dm-3 (56 sectors) [83609.685192] btrfs-transacti(726):
WRITE block 78547376 on dm-3 (56 sectors) [83609.685204]
btrfs-transacti(726): WRITE block 78285296 on dm-3 (16 sectors)
[83609.685209] btrfs-transacti(726): WRITE block 78547440 on dm-3 (16
sectors) [83609.685210] btrfs-submit-1(693): WRITE block 200457016 on
dm-3 (424 sectors) [83609.685239] btrfs-transacti(726): WRITE block
78285312 on dm-3 (128 sectors) [83609.685243] btrfs-transacti(726):
WRITE block 78547456 on dm-3 (128 sectors) [83609.685273]
btrfs-transacti(726): WRITE block 78285440 on dm-3 (128 sectors)
[83609.685276] btrfs-transacti(726): WRITE block 78547584 on dm-3 (128
sectors) [83609.685295] btrfs-submit-1(693): WRITE block 200459520 on
dm-3 (1024 sectors) [83609.685305] btrfs-transacti(726): WRITE block
78285568 on dm-3 (128 sectors) [83609.685308] btrfs-transacti(726):
WRITE block 78547712 on dm-3 (128 sectors) [83609.685324]
btrfs-transacti(726): WRITE block 78285696 on dm-3 (56 sectors)
[83609.685327] btrfs-transacti(726): WRITE block 78547840 on dm-3 (56
sectors) [83609.685330] btrfs-submit-1(693): WRITE block 200460544 on
dm-3 (416 sectors) [83609.685335] btrfs-transacti(726): WRITE block
78285760 on dm-3 (8 sectors) [83609.685340] btrfs-transacti(726):
WRITE block 78547904 on dm-3 (8 sectors) [83609.685354]
btrfs-transacti(726): WRITE block 78285776 on dm-3 (48 sectors)
[83609.685357] btrfs-transacti(726): WRITE block 78547920 on dm-3 (48
sectors) [83609.685366] btrfs-transacti(726): WRITE block 78285824 on
dm-3 (16 sectors) [83609.685369] btrfs-transacti(726): WRITE block
78547968 on dm-3 (16 sectors) [83609.685387] btrfs-transacti(726):
WRITE block 78285848 on dm-3 (64 sectors) [83609.685391]
btrfs-transacti(726): WRITE block 78547992 on dm-3 (64 sectors)
[83609.685403] btrfs-transacti(726): WRITE block 78285920 on dm-3 (32
sectors) [83609.685407] btrfs-transacti(726): WRITE block 78548064 on
dm-3 (32 sectors) [83609.685413] btrfs-submit-1(693): WRITE block
200476080 on dm-3 (1024 sectors) [83609.685415] btrfs-transacti(726):
WRITE block 78285960 on dm-3 (8 sectors) [83609.685418]
btrfs-transacti(726): WRITE block 78548104 on dm-3 (8 sectors)
[83609.685428] btrfs-transacti(726): WRITE block 78285984 on dm-3 (16
sectors) [83609.685431] btrfs-transacti(726): WRITE block 78548128 on
dm-3 (16 sectors) [83609.685448] btrfs-submit-1(693): WRITE block
200477104 on dm-3 (416 sectors) [83609.685452] btrfs-transacti(726):
WRITE block 78286008 on dm-3 (72 sectors) [83609.685456]
btrfs-transacti(726): WRITE block 78548152 on dm-3 (72 sectors)
[83609.685463] btrfs-transacti(726): WRITE block 78286080 on dm-3 (16
sectors) [83609.685467] btrfs-transacti(726): WRITE block 78548224 on
dm-3 (16 sectors) [83609.685489] btrfs-transacti(726): WRITE block
78286104 on dm-3 (88 sectors) [83609.685492] btrfs-transacti(726):
WRITE block 78548248 on dm-3 (88 sectors) [83609.685513]
btrfs-transacti(726): WRITE block 78286264 on dm-3 (72 sectors)
[83609.685516] btrfs-transacti(726): WRITE block 78548408 on dm-3 (72
sectors) [83609.685532] btrfs-submit-1(693): WRITE block 200486248 on
dm-3 (1024 sectors) [83609.685533] btrfs-transacti(726): WRITE block
78286344 on dm-3 (56 sectors) [83609.685537] btrfs-transacti(726):
WRITE block 78548488 on dm-3 (56 sectors) [83609.685556]
btrfs-transacti(726): WRITE block 78286496 on dm-3 (72 sectors)
[83609.685561] btrfs-transacti(726): WRITE block 78548640 on dm-3 (72
sectors) [83609.685567] btrfs-submit-1(693): WRITE block 200487272 on
dm-3 (416 sectors) [83609.685576] btrfs-transacti(726): WRITE block
78286664 on dm-3 (48 sectors) [83609.685579] btrfs-transacti(726):
WRITE block 78548808 on dm-3 (48 sectors) [83609.685605]
btrfs-transacti(726): WRITE block 78286720 on dm-3 (104 sectors)
[83609.685608] btrfs-transacti(726): WRITE block 78548864 on dm-3 (104
sectors) [83609.685618] btrfs-transacti(726): WRITE block 78286840 on
dm-3 (8 sectors) [83609.685621] btrfs-transacti(726): WRITE block
78548984 on dm-3 (8 sectors) [83609.685649] btrfs-transacti(726):
WRITE block 78286848 on dm-3 (128 sectors) [83609.685651]
btrfs-submit-1(693): WRITE block 201835912 on dm-3 (1024 sectors)
[83609.685654] btrfs-transacti(726): WRITE block 78548992 on dm-3 (128
sectors) [83609.685668] btrfs-transacti(726): WRITE block 78286976 on
dm-3 (48 sectors) [83609.685671] btrfs-transacti(726): WRITE block
78549120 on dm-3 (48 sectors) [83609.685686] btrfs-transacti(726):
WRITE block 78287056 on dm-3 (40 sectors) [83609.685687]
btrfs-submit-1(693): WRITE block 201836936 on dm-3 (416 sectors)
[83609.685691] btrfs-transacti(726): WRITE block 78549200 on dm-3 (40
sectors) [83609.685710] btrfs-transacti(726): WRITE block 78287104 on
dm-3 (72 sectors) [83609.685715] btrfs-transacti(726): WRITE block
78549248 on dm-3 (72 sectors) [83609.685723] btrfs-transacti(726):
WRITE block 78287184 on dm-3 (8 sectors) [83609.685727]
btrfs-transacti(726): WRITE block 78549328 on dm-3 (8 sectors)
[83609.685738] btrfs-transacti(726): WRITE block 78287208 on dm-3 (24
sectors) [83609.685741] btrfs-transacti(726): WRITE block 78549352 on
dm-3 (24 sectors) [83609.685766] btrfs-submit-1(693): WRITE block
203684416 on dm-3 (1024 sectors) [83609.685771] btrfs-transacti(726):
WRITE block 78287232 on dm-3 (128 sectors) [83609.685774]
btrfs-transacti(726): WRITE block 78549376 on dm-3 (128 sectors)
[83609.685786] btrfs-transacti(726): WRITE block 78287360 on dm-3 (32
sectors) [83609.685789] btrfs-transacti(726): WRITE block 78549504 on
dm-3 (32 sectors) [83609.685801] btrfs-submit-1(693): WRITE block
203685440 on dm-3 (416 sectors) [83609.685809] btrfs-transacti(726):
WRITE block 78287408 on dm-3 (80 sectors) [83609.685814]
btrfs-transacti(726): WRITE block 78549552 on dm-3 (80 sectors)
[83609.685822] btrfs-transacti(726): WRITE block 78287488 on dm-3 (16
sectors) [83609.685825] btrfs-transacti(726): WRITE block 78549632 on
dm-3 (16 sectors) [83609.685836] btrfs-submit-1(693): WRITE block
205689032 on dm-3 (416 sectors) [83609.685838] btrfs-transacti(726):
WRITE block 78287520 on dm-3 (32 sectors) [83609.685841]
btrfs-transacti(726): WRITE block 78549664 on dm-3 (32 sectors)
[83609.685859] btrfs-transacti(726): WRITE block 78287560 on dm-3 (56
sectors) [83609.685864] btrfs-transacti(726): WRITE block 78549704 on
dm-3 (56 sectors) [83609.685893] btrfs-transacti(726): WRITE block
78287616 on dm-3 (128 sectors) [83609.685897] btrfs-transacti(726):
WRITE block 78549760 on dm-3 (128 sectors) [83609.685909]
btrfs-transacti(726): WRITE block 78287744 on dm-3 (40 sectors)
[83609.685912] btrfs-transacti(726): WRITE block 78549888 on dm-3 (40
sectors) [83609.685918] btrfs-submit-1(693): WRITE block 205689448 on
dm-3 (1024 sectors) [83609.685925] btrfs-transacti(726): WRITE block
78287800 on dm-3 (32 sectors) [83609.685928] btrfs-transacti(726):
WRITE block 78549944 on dm-3 (32 sectors) [83609.685942]
btrfs-transacti(726): WRITE block 78287840 on dm-3 (32 sectors)
[83609.685945] btrfs-transacti(726): WRITE block 78549984 on dm-3 (32
sectors) [83609.685955] btrfs-transacti(726): WRITE block 78287872 on
dm-3 (32 sectors) [83609.685959] btrfs-transacti(726): WRITE block
78550016 on dm-3 (32 sectors) [83609.685967] btrfs-transacti(726):
WRITE block 78287912 on dm-3 (8 sectors) [83609.685970]
btrfs-transacti(726): WRITE block 78550056 on dm-3 (8 sectors)
[83609.685986] btrfs-transacti(726): WRITE block 78287928 on dm-3 (48
sectors) [83609.685989] btrfs-transacti(726): WRITE block 78550072 on
dm-3 (48 sectors) [83609.686002] btrfs-submit-1(693): WRITE block
215137552 on dm-3 (1024 sectors) [83609.686003] btrfs-transacti(726):
WRITE block 78287984 on dm-3 (16 sectors) [83609.686009]
btrfs-transacti(726): WRITE block 78550128 on dm-3 (16 sectors)
[83609.686030] btrfs-transacti(726): WRITE block 78288000 on dm-3 (56
sectors) [83609.686034] btrfs-transacti(726): WRITE block 78550144 on
dm-3 (56 sectors) [83609.686036] btrfs-submit-1(693): WRITE block
215138576 on dm-3 (408 sectors) [83609.686067] btrfs-transacti(726):
WRITE block 78288064 on dm-3 (56 sectors) [83609.686072]
btrfs-transacti(726): WRITE block 78550208 on dm-3 (56 sectors)
[83609.686087] btrfs-transacti(726): WRITE block 78288128 on dm-3 (24
sectors) [83609.686091] btrfs-transacti(726): WRITE block 78550272 on
dm-3 (24 sectors) [83609.686126] btrfs-transacti(726): WRITE block
78288160 on dm-3 (96 sectors) [83609.686127] btrfs-submit-1(693):
WRITE block 215439000 on dm-3 (1024 sectors) [83609.686133]
btrfs-transacti(726): WRITE block 78550304 on dm-3 (96 sectors)
[83609.686144] btrfs-transacti(726): WRITE block 78288272 on dm-3 (8
sectors) [83609.686149] btrfs-transacti(726): WRITE block 78550416 on
dm-3 (8 sectors) [83609.686161] btrfs-submit-1(693): WRITE block
215440024 on dm-3 (408 sectors) [83609.686161] btrfs-transacti(726):
WRITE block 78288288 on dm-3 (24 sectors) [83609.686164]
btrfs-transacti(726): WRITE block 78550432 on dm-3 (24 sectors)
[83609.686186] btrfs-transacti(726): WRITE block 78288320 on dm-3 (64
sectors) [83609.686189] btrfs-transacti(726): WRITE block 78550464 on
dm-3 (64 sectors) [83609.686216] btrfs-transacti(726): WRITE block
78288384 on dm-3 (120 sectors) [83609.686219] btrfs-transacti(726):
WRITE block 78550528 on dm-3 (120 sectors) [83609.686234]
btrfs-transacti(726): WRITE block 78288512 on dm-3 (48 sectors)
[83609.686238] btrfs-transacti(726): WRITE block 78550656 on dm-3 (48
sectors) [83609.686244] btrfs-submit-1(693): WRITE block 216042184 on
dm-3 (1024 sectors) [83609.686247] btrfs-transacti(726): WRITE block
78288568 on dm-3 (16 sectors) [83609.686250] btrfs-transacti(726):
WRITE block 78550712 on dm-3 (16 sectors) [83609.686261]
btrfs-transacti(726): WRITE block 78288592 on dm-3 (16 sectors)
[83609.686264] btrfs-transacti(726): WRITE block 78550736 on dm-3 (16
sectors) [83609.686280] btrfs-submit-1(693): WRITE block 216043208 on
dm-3 (408 sectors) [83609.686403] btrfs-submit-1(693): WRITE block
220179448 on dm-3 (1024 sectors) [83609.686433] btrfs-submit-1(693):
WRITE block 220180472 on dm-3 (408 sectors) [83609.686556]
btrfs-submit-1(693): WRITE block 221405664 on dm-3 (1024 sectors)
[83609.686591] btrfs-submit-1(693): WRITE block 221406688 on dm-3 (408
sectors) [83609.686707] btrfs-submit-1(693): WRITE block 225137976 on
dm-3 (1024 sectors) [83609.686742] btrfs-submit-1(693): WRITE block
225139000 on dm-3 (408 sectors) [83609.686858] btrfs-submit-1(693):
WRITE block 255568688 on dm-3 (1024 sectors) [83609.686891]
btrfs-submit-1(693): WRITE block 255569712 on dm-3 (400 sectors)
[83609.687008] btrfs-submit-1(693): WRITE block 259000152 on dm-3
(1024 sectors) [83609.687041] btrfs-submit-1(693): WRITE block
259001176 on dm-3 (400 sectors) [83609.687217] btrfs-submit-1(693):
WRITE block 284124408 on dm-3 (1024 sectors) [83609.687232]
btrfs-submit-1(693): WRITE block 284125432 on dm-3 (400 sectors)
[83609.687342] btrfs-submit-1(693): WRITE block 284387960 on dm-3
(1024 sectors) [83609.687383] btrfs-submit-1(693): WRITE block
284388984 on dm-3 (400 sectors) [83609.687504] btrfs-submit-1(693):
WRITE block 284751576 on dm-3 (1024 sectors) [83609.687514]
btrfs-submit-1(693): WRITE block 284752600 on dm-3 (128 sectors)
[83609.687549] btrfs-submit-1(693): WRITE block 284752728 on dm-3 (272
sectors) [83609.687641] btrfs-submit-1(693): WRITE block 286830344 on
dm-3 (1024 sectors) [83609.687672] btrfs-submit-1(693): WRITE block
286831368 on dm-3 (392 sectors) [83609.687792] btrfs-submit-1(693):
WRITE block 292350944 on dm-3 (1024 sectors) [83609.687824]
btrfs-submit-1(693): WRITE block 292351968 on dm-3 (392 sectors)
[83609.687941] btrfs-submit-1(693): WRITE block 292538496 on dm-3
(1024 sectors) [83609.687980] btrfs-submit-1(693): WRITE block
292539520 on dm-3 (392 sectors) [83609.688139] btrfs-submit-1(693):
WRITE block 296389080 on dm-3 (1024 sectors) [83609.688170]
btrfs-submit-1(693): WRITE block 296390104 on dm-3 (392 sectors)
[83609.688251] btrfs-submit-1(693): WRITE block 296675520 on dm-3
(1024 sectors) [83609.688284] btrfs-submit-1(693): WRITE block
296676544 on dm-3 (392 sectors) [83609.688395] btrfs-submit-1(693):
WRITE block 298143128 on dm-3 (1024 sectors) [83609.688426]
btrfs-submit-1(693): WRITE block 298144152 on dm-3 (392 sectors)
[83609.688541] btrfs-submit-1(693): WRITE block 299945304 on dm-3
(1024 sectors) [83609.688580] btrfs-submit-1(693): WRITE block
299946328 on dm-3 (384 sectors) [83609.688708] btrfs-submit-1(693):
WRITE block 300151136 on dm-3 (1024 sectors) [83609.688747]
btrfs-submit-1(693): WRITE block 300152160 on dm-3 (384 sectors)
[83609.688841] btrfs-submit-1(693): WRITE block 301536904 on dm-3
(1024 sectors) [83609.688875] btrfs-submit-1(693): WRITE block
301537928 on dm-3 (384 sectors) [83609.688991] btrfs-submit-1(693):
WRITE block 306626128 on dm-3 (1024 sectors) [83609.689028]
btrfs-submit-1(693): WRITE block 306627152 on dm-3 (384 sectors)
[83609.689146] btrfs-submit-1(693): WRITE block 306727256 on dm-3
(1024 sectors) [83609.689184] btrfs-submit-1(693): WRITE block
306728280 on dm-3 (384 sectors) [83609.689238] btrfs-submit-1(693):
WRITE block 307837560 on dm-3 (656 sectors) [83609.689314]
btrfs-submit-1(693): WRITE block 307838216 on dm-3 (752 sectors)
[83609.689440] btrfs-submit-1(693): WRITE block 309639072 on dm-3
(1024 sectors) [83609.689470] btrfs-submit-1(693): WRITE block
309640096 on dm-3 (376 sectors) [83609.689574] btrfs-submit-1(693):
WRITE block 309844248 on dm-3 (1024 sectors) [83609.689603]
btrfs-submit-1(693): WRITE block 309845272 on dm-3 (376 sectors)
[83609.689713] btrfs-submit-1(693): WRITE block 310376856 on dm-3
(1024 sectors) [83609.689741] btrfs-submit-1(693): WRITE block
310377880 on dm-3 (376 sectors) [83609.689847] btrfs-submit-1(693):
WRITE block 312020024 on dm-3 (1024 sectors) [83609.689876]
btrfs-submit-1(693): WRITE block 312021048 on dm-3 (376 sectors)
[83609.689982] btrfs-submit-1(693): WRITE block 312495152 on dm-3
(1024 sectors) [83609.690013] btrfs-submit-1(693): WRITE block
312496176 on dm-3 (376 sectors) [83609.690151] btrfs-submit-1(693):
WRITE block 312678296 on dm-3 (1024 sectors) [83609.690158]
btrfs-submit-1(693): WRITE block 312679320 on dm-3 (376 sectors)
[83609.690262] btrfs-submit-1(693): WRITE block 312812320 on dm-3
(1024 sectors) [83609.690291] btrfs-submit-1(693): WRITE block
312813344 on dm-3 (368 sectors) [83609.690406] btrfs-submit-1(693):
WRITE block 322611592 on dm-3 (1024 sectors) [83609.690442]
btrfs-submit-1(693): WRITE block 322612616 on dm-3 (368 sectors)
[83609.690548] btrfs-submit-1(693): WRITE block 323977552 on dm-3
(1024 sectors) [83609.690578] btrfs-submit-1(693): WRITE block
323978576 on dm-3 (368 sectors) [83609.690671] btrfs-submit-1(693):
WRITE block 324587160 on dm-3 (1024 sectors) [83609.690699]
btrfs-submit-1(693): WRITE block 324588184 on dm-3 (368 sectors)
[83609.690800] btrfs-submit-1(693): WRITE block 325687032 on dm-3
(1024 sectors) [83609.690828] btrfs-submit-1(693): WRITE block
325688056 on dm-3 (368 sectors) [83609.690854] btrfs-submit-1(693):
WRITE block 328055960 on dm-3 (352 sectors) [83609.690982]
btrfs-submit-1(693): WRITE block 328056312 on dm-3 (1024 sectors)
[83609.690985] btrfs-submit-1(693): WRITE block 328057336 on dm-3 (16
sectors) [83609.691115] btrfs-submit-1(693): WRITE block 332311728 on
dm-3 (1024 sectors) [83609.691123] btrfs-submit-1(693): WRITE block
332312752 on dm-3 (360 sectors) [83609.691224] btrfs-submit-1(693):
WRITE block 332902368 on dm-3 (1024 sectors) [83609.691251]
btrfs-submit-1(693): WRITE block 332903392 on dm-3 (360 sectors)
[83609.691360] btrfs-submit-1(693): WRITE block 333372064 on dm-3
(1024 sectors) [83609.691388] btrfs-submit-1(693): WRITE block
333373088 on dm-3 (360 sectors) [83609.691492] btrfs-submit-1(693):
WRITE block 333602416 on dm-3 (1024 sectors) [83609.691519]
btrfs-submit-1(693): WRITE block 333603440 on dm-3 (360 sectors)
[83609.691627] btrfs-submit-1(693): WRITE block 333668648 on dm-3
(1024 sectors) [83609.691654] btrfs-submit-1(693): WRITE block
333669672 on dm-3 (360 sectors) [83609.691765] btrfs-submit-1(693):
WRITE block 340048160 on dm-3 (1024 sectors) [83609.691791]
btrfs-submit-1(693): WRITE block 340049184 on dm-3 (360 sectors)
[83609.691901] btrfs-submit-1(693): WRITE block 340115056 on dm-3
(1024 sectors) [83609.691928] btrfs-submit-1(693): WRITE block
340116080 on dm-3 (352 sectors) [83609.692037] btrfs-submit-1(693):
WRITE block 340241192 on dm-3 (1024 sectors) [83609.692090]
btrfs-submit-1(693): WRITE block 340242216 on dm-3 (352 sectors)
[83609.692196] btrfs-submit-1(693): WRITE block 345940208 on dm-3
(1024 sectors) [83609.692230] btrfs-submit-1(693): WRITE block
345941232 on dm-3 (352 sectors) [83609.692340] btrfs-submit-1(693):
WRITE block 350180976 on dm-3 (1024 sectors) [83609.692374]
btrfs-submit-1(693): WRITE block 350182000 on dm-3 (352 sectors)
[83609.692575] btrfs-submit-1(693): WRITE block 352678120 on dm-3
(1024 sectors) [83609.692613] btrfs-submit-1(693): WRITE block
352679144 on dm-3 (352 sectors) [83609.692637] btrfs-submit-1(693):
WRITE block 353244784 on dm-3 (240 sectors) [83609.692742]
btrfs-submit-1(693): WRITE block 353245024 on dm-3 (1024 sectors)
[83609.692755] btrfs-submit-1(693): WRITE block 353246048 on dm-3 (112
sectors) [83609.692846] btrfs-submit-1(693): WRITE block 239133504 on
dm-3 (1024 sectors) [83609.692950] btrfs-submit-1(693): WRITE block
239134528 on dm-3 (1024 sectors) [83609.693014] btrfs-submit-1(693):
WRITE block 239135552 on dm-3 (696 sectors) [83609.693109]
btrfs-submit-1(693): WRITE block 239762296 on dm-3 (1024 sectors)
[83609.693140] btrfs-submit-1(693): WRITE block 239763320 on dm-3 (344
sectors) [83609.693222] btrfs-submit-1(693): WRITE block 258787312 on
dm-3 (1024 sectors) [83609.693249] btrfs-submit-1(693): WRITE block
258788336 on dm-3 (344 sectors) [83609.693320] btrfs-submit-1(693):
WRITE block 284397536 on dm-3 (1024 sectors) [83609.693346]
btrfs-submit-1(693): WRITE block 284398560 on dm-3 (344 sectors)
[83609.693417] btrfs-submit-1(693): WRITE block 309649432 on dm-3
(1024 sectors) [83609.693443] btrfs-submit-1(693): WRITE block
309650456 on dm-3 (344 sectors) [83609.693549] btrfs-submit-1(693):
WRITE block 312515240 on dm-3 (1024 sectors) [83609.693575]
btrfs-submit-1(693): WRITE block 312516264 on dm-3 (336 sectors)
[83609.693686] btrfs-submit-1(693): WRITE block 312794064 on dm-3
(1024 sectors) [83609.693712] btrfs-submit-1(693): WRITE block
312795088 on dm-3 (336 sectors) [83609.693819] btrfs-submit-1(693):
WRITE block 322770456 on dm-3 (1024 sectors) [83609.693845]
btrfs-submit-1(693): WRITE block 322771480 on dm-3 (336 sectors)
[83609.693952] btrfs-submit-1(693): WRITE block 332926696 on dm-3
(1024 sectors) [83609.693978] btrfs-submit-1(693): WRITE block
332927720 on dm-3 (336 sectors) [83609.694099] btrfs-submit-1(693):
WRITE block 354075024 on dm-3 (1024 sectors) [83609.694122]
btrfs-submit-1(693): WRITE block 354076048 on dm-3 (336 sectors)
[83609.694146] btrfs-submit-1(693): WRITE block 354076600 on dm-3 (312
sectors) [83609.694264] btrfs-submit-1(693): WRITE block 354076912 on
dm-3 (1024 sectors) [83609.694268] btrfs-submit-1(693): WRITE block
354077936 on dm-3 (24 sectors) [83609.694372] btrfs-submit-1(693):
WRITE block 358423048 on dm-3 (1024 sectors) [83609.694397]
btrfs-submit-1(693): WRITE block 358424072 on dm-3 (328 sectors)
[83609.694507] btrfs-submit-1(693): WRITE block 40984792 on dm-3 (1024
sectors) [83609.694532] btrfs-submit-1(693): WRITE block 40985816 on
dm-3 (328 sectors) [83609.694640] btrfs-submit-1(693): WRITE block
44905944 on dm-3 (1024 sectors) [83609.694665] btrfs-submit-1(693):
WRITE block 44906968 on dm-3 (328 sectors) [83609.694772]
btrfs-submit-1(693): WRITE block 46156272 on dm-3 (1024 sectors)
[83609.694797] btrfs-submit-1(693): WRITE block 46157296 on dm-3 (328
sectors) [83609.694905] btrfs-submit-1(693): WRITE block 48466184 on
dm-3 (1024 sectors) [83609.694929] btrfs-submit-1(693): WRITE block
48467208 on dm-3 (328 sectors) [83609.695035] btrfs-submit-1(693):
WRITE block 48518872 on dm-3 (1024 sectors) [83609.695091]
btrfs-submit-1(693): WRITE block 48519896 on dm-3 (328 sectors)
[83609.695168] btrfs-submit-1(693): WRITE block 52837840 on dm-3 (1024
sectors) [83609.695192] btrfs-submit-1(693): WRITE block 52838864 on
dm-3 (320 sectors) [83609.695301] btrfs-submit-1(693): WRITE block
52981200 on dm-3 (1024 sectors) [83609.695324] btrfs-submit-1(693):
WRITE block 52982224 on dm-3 (320 sectors) [83609.695428]
btrfs-submit-1(693): WRITE block 56427600 on dm-3 (1024 sectors)
[83609.695452] btrfs-submit-1(693): WRITE block 56428624 on dm-3 (320
sectors) [83609.695554] btrfs-submit-1(693): WRITE block 56700424 on
dm-3 (1024 sectors) [83609.695577] btrfs-submit-1(693): WRITE block
56701448 on dm-3 (320 sectors) [83609.695683] btrfs-submit-1(693):
WRITE block 57811800 on dm-3 (1024 sectors) [83609.695708]
btrfs-submit-1(693): WRITE block 57812824 on dm-3 (320 sectors)
[83609.695749] btrfs-submit-1(693): WRITE block 58096008 on dm-3 (584
sectors) [83609.695824] btrfs-submit-1(693): WRITE block 58096592 on
dm-3 (760 sectors) [83609.695937] btrfs-submit-1(693): WRITE block
63247280 on dm-3 (1024 sectors) [83609.695960] btrfs-submit-1(693):
WRITE block 63248304 on dm-3 (312 sectors) [83609.696069]
btrfs-submit-1(693): WRITE block 63315088 on dm-3 (1024 sectors)
[83609.696093] btrfs-submit-1(693): WRITE block 63316112 on dm-3 (312
sectors) [83609.696193] btrfs-submit-1(693): WRITE block 63861888 on
dm-3 (1024 sectors) [83609.696216] btrfs-submit-1(693): WRITE block
63862912 on dm-3 (312 sectors) [83609.696320] btrfs-submit-1(693):
WRITE block 63942808 on dm-3 (1024 sectors) [83609.696345]
btrfs-submit-1(693): WRITE block 63943832 on dm-3 (312 sectors)
[83609.696446] btrfs-submit-1(693): WRITE block 64234792 on dm-3 (1024
sectors) [83609.696469] btrfs-submit-1(693): WRITE block 64235816 on
dm-3 (312 sectors) [83609.696571] btrfs-submit-1(693): WRITE block
74092112 on dm-3 (1024 sectors) [83609.696594] btrfs-submit-1(693):
WRITE block 74093136 on dm-3 (312 sectors) [83609.696697]
btrfs-submit-1(693): WRITE block 77553336 on dm-3 (1024 sectors)
[83609.696720] btrfs-submit-1(693): WRITE block 77554360 on dm-3 (304
sectors) [83609.696820] btrfs-submit-1(693): WRITE block 80407528 on
dm-3 (1024 sectors) [83609.696843] btrfs-submit-1(693): WRITE block
80408552 on dm-3 (304 sectors) [83609.696954] btrfs-submit-1(693):
WRITE block 81857936 on dm-3 (1024 sectors) [83609.696977]
btrfs-submit-1(693): WRITE block 81858960 on dm-3 (304 sectors)
[83609.697089] btrfs-submit-1(693): WRITE block 99864936 on dm-3 (1024
sectors) [83609.697111] btrfs-submit-1(693): WRITE block 99865960 on
dm-3 (304 sectors) [83609.697216] btrfs-submit-1(693): WRITE block
106045848 on dm-3 (1024 sectors) [83609.697238] btrfs-submit-1(693):
WRITE block 106046872 on dm-3 (304 sectors) [83609.697342]
btrfs-submit-1(693): WRITE block 108124880 on dm-3 (1024 sectors)
[83609.697345] btrfs-submit-1(693): WRITE block 108125904 on dm-3 (24
sectors) [83609.697367] btrfs-submit-1(693): WRITE block 108125928 on
dm-3 (280 sectors) [83609.697476] btrfs-submit-1(693): WRITE block
116819160 on dm-3 (1024 sectors) [83609.697498] btrfs-submit-1(693):
WRITE block 116820184 on dm-3 (296 sectors) [83609.697609]
btrfs-submit-1(693): WRITE block 116823704 on dm-3 (1024 sectors)
[83609.697631] btrfs-submit-1(693): WRITE block 116824728 on dm-3 (296
sectors) [83609.697737] btrfs-submit-1(693): WRITE block 117248672 on
dm-3 (1024 sectors) [83609.697760] btrfs-submit-1(693): WRITE block
117249696 on dm-3 (296 sectors) [83609.697865] btrfs-submit-1(693):
WRITE block 133985712 on dm-3 (1024 sectors) [83609.697962]
btrfs-submit-1(693): WRITE block 133986736 on dm-3 (1024 sectors)
[83609.698006] btrfs-submit-1(693): WRITE block 133987760 on dm-3 (592
sectors) [83609.698126] btrfs-submit-1(693): WRITE block 135562472 on
dm-3 (1024 sectors) [83609.698147] btrfs-submit-1(693): WRITE block
135563496 on dm-3 (296 sectors) [83609.698254] btrfs-submit-1(693):
WRITE block 45903632 on dm-3 (1024 sectors) [83609.698353]
btrfs-submit-1(693): WRITE block 45904656 on dm-3 (1024 sectors)
[83609.698394] btrfs-submit-1(693): WRITE block 45905680 on dm-3 (584
sectors) [83609.698510] btrfs-submit-1(693): WRITE block 358677232 on
dm-3 (1024 sectors) [83609.698629] btrfs-submit-1(693): WRITE block
358678256 on dm-3 (1024 sectors) [83609.698654] btrfs-submit-1(693):
WRITE block 358679280 on dm-3 (584 sectors) [83609.698768]
btrfs-submit-1(693): WRITE block 52563056 on dm-3 (1024 sectors)
[83609.698793] btrfs-submit-1(693): WRITE block 52564080 on dm-3 (288
sectors) [83609.698925] btrfs-submit-1(693): WRITE block 64293736 on
dm-3 (1024 sectors) [83609.698937] btrfs-submit-1(693): WRITE block
64294760 on dm-3 (288 sectors) [83609.698950] btrfs-submit-1(693):
WRITE block 122383848 on dm-3 (376 sectors) [83609.699053]
btrfs-submit-1(693): WRITE block 122384224 on dm-3 (936 sectors)
[83609.699185] btrfs-submit-1(693): WRITE block 149492944 on dm-3
(1024 sectors) [83609.699194] btrfs-submit-1(693): WRITE block
149493968 on dm-3 (280 sectors) [83609.699284] btrfs-submit-1(693):
WRITE block 150343760 on dm-3 (1024 sectors) [83609.699305]
btrfs-submit-1(693): WRITE block 150344784 on dm-3 (280 sectors)
[83609.699411] btrfs-submit-1(693): WRITE block 168562280 on dm-3
(1024 sectors) [83609.699431] btrfs-submit-1(693): WRITE block
168563304 on dm-3 (280 sectors) [83609.699538] btrfs-submit-1(693):
WRITE block 171054600 on dm-3 (1024 sectors) [83609.699559]
btrfs-submit-1(693): WRITE block 171055624 on dm-3 (280 sectors)
[83609.699679] btrfs-submit-1(693): WRITE block 175808480 on dm-3
(1024 sectors) [83609.699690] btrfs-submit-1(693): WRITE block
175809504 on dm-3 (280 sectors) [83609.699791] btrfs-submit-1(693):
WRITE block 176155648 on dm-3 (1024 sectors) [83609.699822]
btrfs-submit-1(693): WRITE block 176156672 on dm-3 (280 sectors)
[83609.699924] btrfs-submit-1(693): WRITE block 183372696 on dm-3
(1024 sectors) [83609.699944] btrfs-submit-1(693): WRITE block
183373720 on dm-3 (272 sectors) [83609.700047] btrfs-submit-1(693):
WRITE block 188922416 on dm-3 (1024 sectors) [83609.700075]
btrfs-submit-1(693): WRITE block 188923440 on dm-3 (272 sectors)
[83609.700179] btrfs-submit-1(693): WRITE block 190376400 on dm-3
(1024 sectors) [83609.700198] btrfs-submit-1(693): WRITE block
190377424 on dm-3 (272 sectors) [83609.700306] btrfs-submit-1(693):
WRITE block 199897248 on dm-3 (1024 sectors) [83609.700327]
btrfs-submit-1(693): WRITE block 199898272 on dm-3 (272 sectors)
[83609.700431] btrfs-submit-1(693): WRITE block 200498048 on dm-3
(1024 sectors) [83609.700452] btrfs-submit-1(693): WRITE block
200499072 on dm-3 (272 sectors) [83609.700560] btrfs-submit-1(693):
WRITE block 203113480 on dm-3 (1024 sectors) [83609.700576]
btrfs-submit-1(693): WRITE block 203114504 on dm-3 (200 sectors)
[83609.700583] btrfs-submit-1(693): WRITE block 203114704 on dm-3 (72
sectors) [83609.700694] btrfs-submit-1(693): WRITE block 203993480 on
dm-3 (1024 sectors) [83609.700714] btrfs-submit-1(693): WRITE block
203994504 on dm-3 (264 sectors) [83609.700817] btrfs-submit-1(693):
WRITE block 220194056 on dm-3 (1024 sectors) [83609.700837]
btrfs-submit-1(693): WRITE block 220195080 on dm-3 (264 sectors)
[83609.700944] btrfs-submit-1(693): WRITE block 224743312 on dm-3
(1024 sectors) [83609.700964] btrfs-submit-1(693): WRITE block
224744336 on dm-3 (264 sectors) [83609.701091] btrfs-submit-1(693):
WRITE block 234076448 on dm-3 (1024 sectors) [83609.701100]
btrfs-submit-1(693): WRITE block 234077472 on dm-3 (264 sectors)
[83609.701197] btrfs-submit-1(693): WRITE block 282732528 on dm-3
(1024 sectors) [83609.701217] btrfs-submit-1(693): WRITE block
282733552 on dm-3 (264 sectors) [83609.701326] btrfs-submit-1(693):
WRITE block 309032552 on dm-3 (1024 sectors) [83609.701346]
btrfs-submit-1(693): WRITE block 309033576 on dm-3 (264 sectors)
[83609.701457] btrfs-submit-1(693): WRITE block 338511472 on dm-3
(1024 sectors) [83609.701478] btrfs-submit-1(693): WRITE block
338512496 on dm-3 (264 sectors) [83609.701590] btrfs-submit-1(693):
WRITE block 346185392 on dm-3 (1024 sectors) [83609.701610]
btrfs-submit-1(693): WRITE block 346186416 on dm-3 (256 sectors)
[83609.701717] btrfs-submit-1(693): WRITE block 45090888 on dm-3 (1024
sectors) [83609.701737] btrfs-submit-1(693): WRITE block 45091912 on
dm-3 (256 sectors) [83609.701842] btrfs-submit-1(693): WRITE block
190381160 on dm-3 (1024 sectors) [83609.701862] btrfs-submit-1(693):
WRITE block 190382184 on dm-3 (256 sectors) [83609.701968]
btrfs-submit-1(693): WRITE block 225340200 on dm-3 (1024 sectors)
[83609.702108] btrfs-submit-1(693): WRITE block 225341224 on dm-3
(1024 sectors) [83609.702123] btrfs-submit-1(693): WRITE block
225342248 on dm-3 (512 sectors) [83609.702219] btrfs-submit-1(693):
WRITE block 45096176 on dm-3 (976 sectors) [83609.702243]
btrfs-submit-1(693): WRITE block 45097152 on dm-3 (304 sectors)
[83609.702355] btrfs-submit-1(693): WRITE block 45167704 on dm-3 (1024
sectors) [83609.702374] btrfs-submit-1(693): WRITE block 45168728 on
dm-3 (248 sectors) [83609.702476] btrfs-submit-1(693): WRITE block
47120216 on dm-3 (1024 sectors) [83609.702575] btrfs-submit-1(693):
WRITE block 47121240 on dm-3 (1024 sectors) [83609.702611]
btrfs-submit-1(693): WRITE block 47122264 on dm-3 (496 sectors)
[83609.702721] btrfs-submit-1(693): WRITE block 47283640 on dm-3 (1024
sectors) [83609.702740] btrfs-submit-1(693): WRITE block 47284664 on
dm-3 (248 sectors) [83609.702849] btrfs-submit-1(693): WRITE block
49068936 on dm-3 (1024 sectors) [83609.702868] btrfs-submit-1(693):
WRITE block 49069960 on dm-3 (248 sectors) [83609.702972]
btrfs-submit-1(693): WRITE block 51865544 on dm-3 (1024 sectors)
[83609.702991] btrfs-submit-1(693): WRITE block 51866568 on dm-3 (248
sectors) [83609.703111] btrfs-submit-1(693): WRITE block 40905600 on
dm-3 (1024 sectors) [83609.703135] btrfs-submit-1(693): WRITE block
40906624 on dm-3 (240 sectors) [83609.703248] btrfs-submit-1(693):
WRITE block 52759176 on dm-3 (1024 sectors) [83609.703271]
btrfs-submit-1(693): WRITE block 52760200 on dm-3 (240 sectors)
[83609.703368] btrfs-submit-1(693): WRITE block 58828584 on dm-3 (1024
sectors) [83609.703389] btrfs-submit-1(693): WRITE block 58829608 on
dm-3 (240 sectors) [83609.703469] btrfs-submit-1(693): WRITE block
59313504 on dm-3 (1024 sectors) [83609.703487] btrfs-submit-1(693):
WRITE block 59314528 on dm-3 (240 sectors) [83609.703588]
btrfs-submit-1(693): WRITE block 60883440 on dm-3 (1024 sectors)
[83609.703607] btrfs-submit-1(693): WRITE block 60884464 on dm-3 (240
sectors) [83609.703708] btrfs-submit-1(693): WRITE block 62079024 on
dm-3 (1024 sectors) [83609.703726] btrfs-submit-1(693): WRITE block
62080048 on dm-3 (240 sectors) [83609.703819] btrfs-submit-1(693):
WRITE block 62974432 on dm-3 (944 sectors) [83609.703842]
btrfs-submit-1(693): WRITE block 62975376 on dm-3 (320 sectors)
[83609.703959] btrfs-submit-1(693): WRITE block 62979392 on dm-3 (1024
sectors) [83609.703978] btrfs-submit-1(693): WRITE block 62980416 on
dm-3 (232 sectors) [83609.704094] btrfs-submit-1(693): WRITE block
106844104 on dm-3 (1024 sectors) [83609.704113] btrfs-submit-1(693):
WRITE block 106845128 on dm-3 (232 sectors) [83609.704206]
btrfs-submit-1(693): WRITE block 116857416 on dm-3 (1024 sectors)
[83609.704224] btrfs-submit-1(693): WRITE block 116858440 on dm-3 (232
sectors) [83609.704329] btrfs-submit-1(693): WRITE block 118856224 on
dm-3 (1024 sectors) [83609.704347] btrfs-submit-1(693): WRITE block
118857248 on dm-3 (232 sectors) [83609.704449] btrfs-submit-1(693):
WRITE block 118874312 on dm-3 (1024 sectors) [83609.704468]
btrfs-submit-1(693): WRITE block 118875336 on dm-3 (232 sectors)
[83609.704570] btrfs-submit-1(693): WRITE block 128142232 on dm-3
(1024 sectors) [83609.704588] btrfs-submit-1(693): WRITE block
128143256 on dm-3 (232 sectors) [83609.704697] btrfs-submit-1(693):
WRITE block 203317560 on dm-3 (1024 sectors) [83609.704714]
btrfs-submit-1(693): WRITE block 203318584 on dm-3 (224 sectors)
[83609.704817] btrfs-submit-1(693): WRITE block 246934856 on dm-3
(1024 sectors) [83609.704834] btrfs-submit-1(693): WRITE block
246935880 on dm-3 (224 sectors) [83609.704940] btrfs-submit-1(693):
WRITE block 313069240 on dm-3 (1024 sectors) [83609.704958]
btrfs-submit-1(693): WRITE block 313070264 on dm-3 (224 sectors)
[83609.705098] btrfs-submit-1(693): WRITE block 313380056 on dm-3
(1024 sectors) [83609.705107] btrfs-submit-1(693): WRITE block
313381080 on dm-3 (224 sectors) [83609.705193] btrfs-submit-1(693):
WRITE block 292663472 on dm-3 (1024 sectors) [83609.705293]
btrfs-submit-1(693): WRITE block 292664496 on dm-3 (1024 sectors)
[83609.705326] btrfs-submit-1(693): WRITE block 292665520 on dm-3 (448
sectors) [83609.705440] btrfs-submit-1(693): WRITE block 128391640 on
dm-3 (1024 sectors) [83609.705448] btrfs-submit-1(693): WRITE block
128392664 on dm-3 (96 sectors) [83609.705458] btrfs-submit-1(693):
WRITE block 128392760 on dm-3 (128 sectors) [83609.705562]
btrfs-submit-1(693): WRITE block 67307704 on dm-3 (1024 sectors)
[83609.705579] btrfs-submit-1(693): WRITE block 67308728 on dm-3 (216
sectors) [83609.705682] btrfs-submit-1(693): WRITE block 118889848 on
dm-3 (1024 sectors) [83609.705699] btrfs-submit-1(693): WRITE block
118890872 on dm-3 (216 sectors) [83609.705794] btrfs-submit-1(693):
WRITE block 134910344 on dm-3 (1024 sectors) [83609.705810]
btrfs-submit-1(693): WRITE block 134911368 on dm-3 (216 sectors)
[83609.705879] btrfs-submit-1(693): WRITE block 137100992 on dm-3
(1024 sectors) [83609.705896] btrfs-submit-1(693): WRITE block
137102016 on dm-3 (216 sectors) [83609.705965] btrfs-submit-1(693):
WRITE block 137839704 on dm-3 (1024 sectors) [83609.705981]
btrfs-submit-1(693): WRITE block 137840728 on dm-3 (216 sectors)
[83609.706051] btrfs-submit-1(693): WRITE block 141367376 on dm-3
(1024 sectors) [83609.706105] btrfs-submit-1(693): WRITE block
141368400 on dm-3 (216 sectors) [83609.706142] btrfs-submit-1(693):
WRITE block 150820512 on dm-3 (1024 sectors) [83609.706159]
btrfs-submit-1(693): WRITE block 150821536 on dm-3 (216 sectors)
[83609.706227] btrfs-submit-1(693): WRITE block 162019752 on dm-3
(1024 sectors) [83609.706244] btrfs-submit-1(693): WRITE block
162020776 on dm-3 (208 sectors) [83609.706342] btrfs-submit-1(693):
WRITE block 175750904 on dm-3 (1024 sectors) [83609.706358]
btrfs-submit-1(693): WRITE block 175751928 on dm-3 (208 sectors)
[83609.706428] btrfs-submit-1(693): WRITE block 176101424 on dm-3
(1024 sectors) [83609.706444] btrfs-submit-1(693): WRITE block
176102448 on dm-3 (208 sectors) [83609.706513] btrfs-submit-1(693):
WRITE block 183584912 on dm-3 (1024 sectors) [83609.706529]
btrfs-submit-1(693): WRITE block 183585936 on dm-3 (208 sectors)
[83609.706597] btrfs-submit-1(693): WRITE block 183969952 on dm-3
(1024 sectors) [83609.706614] btrfs-submit-1(693): WRITE block
183970976 on dm-3 (208 sectors) [83609.706685] btrfs-submit-1(693):
WRITE block 184051472 on dm-3 (1024 sectors) [83609.706700]
btrfs-submit-1(693): WRITE block 184052496 on dm-3 (208 sectors)
[83609.706721] btrfs-submit-1(693): WRITE block 82310008 on dm-3 (264
sectors) [83609.706788] btrfs-submit-1(693): WRITE block 82310272 on
dm-3 (960 sectors) [83609.706857] btrfs-submit-1(693): WRITE block
117000104 on dm-3 (1024 sectors) [83609.706872] btrfs-submit-1(693):
WRITE block 117001128 on dm-3 (200 sectors) [83609.706940]
btrfs-submit-1(693): WRITE block 184073256 on dm-3 (1024 sectors)
[83609.706956] btrfs-submit-1(693): WRITE block 184074280 on dm-3 (200
sectors) [83609.707023] btrfs-submit-1(693): WRITE block 186250504 on
dm-3 (1024 sectors) [83609.707038] btrfs-submit-1(693): WRITE block
186251528 on dm-3 (200 sectors) [83609.707114] btrfs-submit-1(693):
WRITE block 187314392 on dm-3 (1024 sectors) [83609.707128]
btrfs-submit-1(693): WRITE block 187315416 on dm-3 (200 sectors)
[83609.707195] btrfs-submit-1(693): WRITE block 189925288 on dm-3
(1024 sectors) [83609.707210] btrfs-submit-1(693): WRITE block
189926312 on dm-3 (200 sectors) [83609.707305] btrfs-submit-1(693):
WRITE block 189948680 on dm-3 (1024 sectors) [83609.707320]
btrfs-submit-1(693): WRITE block 189949704 on dm-3 (200 sectors)
[83609.707422] btrfs-submit-1(693): WRITE block 67498088 on dm-3 (1024
sectors) [83609.707436] btrfs-submit-1(693): WRITE block 67499112 on
dm-3 (192 sectors) [83609.707539] btrfs-submit-1(693): WRITE block
77622352 on dm-3 (1024 sectors) [83609.707553] btrfs-submit-1(693):
WRITE block 77623376 on dm-3 (192 sectors) [83609.707632]
btrfs-submit-1(693): WRITE block 115063528 on dm-3 (1024 sectors)
[83609.707646] btrfs-submit-1(693): WRITE block 115064552 on dm-3 (192
sectors) [83609.707717] btrfs-submit-1(693): WRITE block 196045832 on
dm-3 (1024 sectors) [83609.707732] btrfs-submit-1(693): WRITE block
196046856 on dm-3 (192 sectors) [83609.707800] btrfs-submit-1(693):
WRITE block 199303816 on dm-3 (1024 sectors) [83609.707814]
btrfs-submit-1(693): WRITE block 199304840 on dm-3 (192 sectors)
[83609.707881] btrfs-submit-1(693): WRITE block 199758864 on dm-3
(1024 sectors) [83609.707895] btrfs-submit-1(693): WRITE block
199759888 on dm-3 (192 sectors) [83609.707954] btrfs-submit-1(693):
WRITE block 202018344 on dm-3 (864 sectors) [83609.707979]
btrfs-submit-1(693): WRITE block 202019208 on dm-3 (352 sectors)
[83609.708047] btrfs-submit-1(693): WRITE block 203508360 on dm-3
(1024 sectors) [83609.708083] btrfs-submit-1(693): WRITE block
203509384 on dm-3 (184 sectors) [83609.708204] btrfs-submit-1(693):
WRITE block 203648112 on dm-3 (1024 sectors) [83609.708210]
btrfs-submit-1(693): WRITE block 203649136 on dm-3 (184 sectors)
[83609.708231] btrfs-submit-1(693): WRITE block 203985520 on dm-3
(1024 sectors) [83609.708245] btrfs-submit-1(693): WRITE block
203986544 on dm-3 (184 sectors) [83609.708346] btrfs-submit-1(693):
WRITE block 212808792 on dm-3 (1024 sectors) [83609.708360]
btrfs-submit-1(693): WRITE block 212809816 on dm-3 (184 sectors)
[83609.708464] btrfs-submit-1(693): WRITE block 219368568 on dm-3
(1024 sectors) [83609.708478] btrfs-submit-1(693): WRITE block
219369592 on dm-3 (184 sectors) [83609.708546] btrfs-submit-1(693):
WRITE block 224744600 on dm-3 (1024 sectors) [83609.708560]
btrfs-submit-1(693): WRITE block 224745624 on dm-3 (184 sectors)
[83609.708626] btrfs-submit-1(693): WRITE block 349483728 on dm-3
(1024 sectors) [83609.708639] btrfs-submit-1(693): WRITE block
349484752 on dm-3 (176 sectors) [83609.708704] btrfs-submit-1(693):
WRITE block 49070208 on dm-3 (1024 sectors) [83609.708717]
btrfs-submit-1(693): WRITE block 49071232 on dm-3 (176 sectors)
[83609.708783] btrfs-submit-1(693): WRITE block 63281704 on dm-3 (1024
sectors) [83609.708797] btrfs-submit-1(693): WRITE block 63282728 on
dm-3 (176 sectors) [83609.708863] btrfs-submit-1(693): WRITE block
63489832 on dm-3 (1024 sectors) [83609.708876] btrfs-submit-1(693):
WRITE block 63490856 on dm-3 (176 sectors) [83609.708942]
btrfs-submit-1(693): WRITE block 67608392 on dm-3 (1024 sectors)
[83609.708955] btrfs-submit-1(693): WRITE block 67609416 on dm-3 (176
sectors) [83609.709020] btrfs-submit-1(693): WRITE block 68313344 on
dm-3 (1024 sectors) [83609.709034] btrfs-submit-1(693): WRITE block
68314368 on dm-3 (176 sectors) [83609.709108] btrfs-submit-1(693):
WRITE block 93887096 on dm-3 (1024 sectors) [83609.709122]
btrfs-submit-1(693): WRITE block 93888120 on dm-3 (176 sectors)
[83609.709152] btrfs-submit-1(693): WRITE block 61805336 on dm-3 (464
sectors) [83609.709199] btrfs-submit-1(693): WRITE block 61805800 on
dm-3 (728 sectors) [83609.709277] btrfs-submit-1(693): WRITE block
66752448 on dm-3 (1024 sectors) [83609.709289] btrfs-submit-1(693):
WRITE block 66753472 on dm-3 (168 sectors) [83609.709393]
btrfs-submit-1(693): WRITE block 68130808 on dm-3 (1024 sectors)
[83609.709406] btrfs-submit-1(693): WRITE block 68131832 on dm-3 (168
sectors) [83609.709508] btrfs-submit-1(693): WRITE block 97992032 on
dm-3 (1024 sectors) [83609.709520] btrfs-submit-1(693): WRITE block
97993056 on dm-3 (168 sectors) [83609.709594] btrfs-submit-1(693):
WRITE block 99328608 on dm-3 (1024 sectors) [83609.709607]
btrfs-submit-1(693): WRITE block 99329632 on dm-3 (168 sectors)
[83609.709672] btrfs-submit-1(693): WRITE block 106138896 on dm-3
(1024 sectors) [83609.709685] btrfs-submit-1(693): WRITE block
106139920 on dm-3 (168 sectors) [83609.709749] btrfs-submit-1(693):
WRITE block 108294560 on dm-3 (1024 sectors) [83609.709764]
btrfs-submit-1(693): WRITE block 108295584 on dm-3 (168 sectors)
[83609.709834] btrfs-submit-1(693): WRITE block 106610696 on dm-3
(1024 sectors) [83609.709847] btrfs-submit-1(693): WRITE block
106611720 on dm-3 (160 sectors) [83609.709916] btrfs-submit-1(693):
WRITE block 106670776 on dm-3 (1024 sectors) [83609.709929]
btrfs-submit-1(693): WRITE block 106671800 on dm-3 (160 sectors)
[83609.709995] btrfs-submit-1(693): WRITE block 117136520 on dm-3
(1024 sectors) [83609.710007] btrfs-submit-1(693): WRITE block
117137544 on dm-3 (160 sectors) [83609.710079] btrfs-submit-1(693):
WRITE block 127386840 on dm-3 (1024 sectors) [83609.710092]
btrfs-submit-1(693): WRITE block 127387864 on dm-3 (160 sectors)
[83609.710158] btrfs-submit-1(693): WRITE block 136509688 on dm-3
(1024 sectors) [83609.710170] btrfs-submit-1(693): WRITE block
136510712 on dm-3 (160 sectors) [83609.710243] btrfs-submit-1(693):
WRITE block 203925856 on dm-3 (1024 sectors) [83609.710255]
btrfs-submit-1(693): WRITE block 203926880 on dm-3 (160 sectors)
[83609.710359] btrfs-submit-1(693): WRITE block 245065304 on dm-3
(1024 sectors) [83609.710371] btrfs-submit-1(693): WRITE block
245066328 on dm-3 (160 sectors) [83609.710392] btrfs-submit-1(693):
WRITE block 361062120 on dm-3 (296 sectors) [83609.710510]
btrfs-submit-1(693): WRITE block 361062416 on dm-3 (1024 sectors)
[83609.710575] btrfs-submit-1(693): WRITE block 361063440 on dm-3
(1024 sectors) [83609.710579] btrfs-submit-1(693): WRITE block
361064464 on dm-3 (16 sectors) [83609.710644] btrfs-submit-1(693):
WRITE block 88840872 on dm-3 (1024 sectors) [83609.710656]
btrfs-submit-1(693): WRITE block 88841896 on dm-3 (152 sectors)
[83609.710721] btrfs-submit-1(693): WRITE block 88923008 on dm-3 (1024
sectors) [83609.710733] btrfs-submit-1(693): WRITE block 88924032 on
dm-3 (152 sectors) [83609.710798] btrfs-submit-1(693): WRITE block
99193712 on dm-3 (1024 sectors) [83609.710810] btrfs-submit-1(693):
WRITE block 99194736 on dm-3 (152 sectors) [83609.710874]
btrfs-submit-1(693): WRITE block 107678496 on dm-3 (1024 sectors)
[83609.710886] btrfs-submit-1(693): WRITE block 107679520 on dm-3 (152
sectors) [83609.710951] btrfs-submit-1(693): WRITE block 121371584 on
dm-3 (1024 sectors) [83609.710963] btrfs-submit-1(693): WRITE block
121372608 on dm-3 (152 sectors) [83609.711028] btrfs-submit-1(693):
WRITE block 47566856 on dm-3 (1024 sectors) [83609.711039]
btrfs-submit-1(693): WRITE block 47567880 on dm-3 (144 sectors)
[83609.711108] btrfs-submit-1(693): WRITE block 64841240 on dm-3 (1024
sectors) [83609.711119] btrfs-submit-1(693): WRITE block 64842264 on
dm-3 (144 sectors) [83609.711184] btrfs-submit-1(693): WRITE block
74093448 on dm-3 (1024 sectors) [83609.711197] btrfs-submit-1(693):
WRITE block 74094472 on dm-3 (144 sectors) [83609.711303]
btrfs-submit-1(693): WRITE block 82929040 on dm-3 (1024 sectors)
[83609.711315] btrfs-submit-1(693): WRITE block 82930064 on dm-3 (144
sectors) [83609.711415] btrfs-submit-1(693): WRITE block 90935448 on
dm-3 (1024 sectors) [83609.711426] btrfs-submit-1(693): WRITE block
90936472 on dm-3 (144 sectors) [83609.711519] btrfs-submit-1(693):
WRITE block 143086224 on dm-3 (1024 sectors) [83609.711531]
btrfs-submit-1(693): WRITE block 143087248 on dm-3 (144 sectors)
[83609.711595] btrfs-submit-1(693): WRITE block 143382216 on dm-3
(1024 sectors) [83609.711607] btrfs-submit-1(693): WRITE block
143383240 on dm-3 (144 sectors) [83609.711630] btrfs-submit-1(693):
WRITE block 82213344 on dm-3 (344 sectors) [83609.711683]
btrfs-submit-1(693): WRITE block 82213688 on dm-3 (816 sectors)
[83609.711747] btrfs-submit-1(693): WRITE block 101210240 on dm-3
(1024 sectors) [83609.711758] btrfs-submit-1(693): WRITE block
101211264 on dm-3 (136 sectors) [83609.711822] btrfs-submit-1(693):
WRITE block 116898992 on dm-3 (1024 sectors) [83609.711832]
btrfs-submit-1(693): WRITE block 116900016 on dm-3 (136 sectors)
[83609.711905] btrfs-submit-1(693): WRITE block 147126000 on dm-3
(1024 sectors) [83609.711916] btrfs-submit-1(693): WRITE block
147127024 on dm-3 (136 sectors) [83609.711984] btrfs-submit-1(693):
WRITE block 161490696 on dm-3 (1024 sectors) [83609.711995]
btrfs-submit-1(693): WRITE block 161491720 on dm-3 (136 sectors)
[83609.712103] btrfs-submit-1(693): WRITE block 162788320 on dm-3
(1024 sectors) [83609.712117] btrfs-submit-1(693): WRITE block
162789344 on dm-3 (136 sectors) [83609.712154] btrfs-submit-1(693):
WRITE block 169653768 on dm-3 (1024 sectors) [83609.712164]
btrfs-submit-1(693): WRITE block 169654792 on dm-3 (136 sectors)
[83609.712268] btrfs-submit-1(693): WRITE block 333207848 on dm-3
(1024 sectors) [83609.712279] btrfs-submit-1(693): WRITE block
333208872 on dm-3 (128 sectors) [83609.712380] btrfs-submit-1(693):
WRITE block 61374880 on dm-3 (1024 sectors) [83609.712389]
btrfs-submit-1(693): WRITE block 61375904 on dm-3 (128 sectors)
[83609.712490] btrfs-submit-1(693): WRITE block 79993704 on dm-3 (1024
sectors) [83609.712500] btrfs-submit-1(693): WRITE block 79994728 on
dm-3 (128 sectors) [83609.712578] btrfs-submit-1(693): WRITE block
81598080 on dm-3 (1024 sectors) [83609.712588] btrfs-submit-1(693):
WRITE block 81599104 on dm-3 (128 sectors) [83609.712653]
btrfs-submit-1(693): WRITE block 89569728 on dm-3 (1024 sectors)
[83609.712662] btrfs-submit-1(693): WRITE block 89570752 on dm-3 (128
sectors) [83609.712727] btrfs-submit-1(693): WRITE block 93705624 on
dm-3 (1024 sectors) [83609.712737] btrfs-submit-1(693): WRITE block
93706648 on dm-3 (128 sectors) [83609.712802] btrfs-submit-1(693):
WRITE block 97902256 on dm-3 (1024 sectors) [83609.712813]
btrfs-submit-1(693): WRITE block 97903280 on dm-3 (128 sectors)
[83609.712853] btrfs-submit-1(693): WRITE block 99230720 on dm-3 (624
sectors) [83609.712893] btrfs-submit-1(693): WRITE block 99231344 on
dm-3 (520 sectors) [83609.712966] btrfs-submit-1(693): WRITE block
186503824 on dm-3 (1024 sectors) [83609.712974] btrfs-submit-1(693):
WRITE block 186504848 on dm-3 (120 sectors) [83609.713042]
btrfs-submit-1(693): WRITE block 193355392 on dm-3 (1024 sectors)
[83609.713052] btrfs-submit-1(693): WRITE block 193356416 on dm-3 (120
sectors) [83609.713131] btrfs-submit-1(693): WRITE block 210282056 on
dm-3 (1024 sectors) [83609.713140] btrfs-submit-1(693): WRITE block
210283080 on dm-3 (120 sectors) [83609.713215] btrfs-submit-1(693):
WRITE block 212807616 on dm-3 (1024 sectors) [83609.713224]
btrfs-submit-1(693): WRITE block 212808640 on dm-3 (120 sectors)
[83609.713330] btrfs-submit-1(693): WRITE block 254206256 on dm-3
(1024 sectors) [83609.713339] btrfs-submit-1(693): WRITE block
254207280 on dm-3 (120 sectors) [83609.713465] btrfs-submit-1(693):
WRITE block 254417704 on dm-3 (1024 sectors) [83609.713478]
btrfs-submit-1(693): WRITE block 254418728 on dm-3 (120 sectors)
[83609.713596] btrfs-submit-1(693): WRITE block 38660928 on dm-3 (1024
sectors) [83609.713602] btrfs-submit-1(693): WRITE block 38661952 on
dm-3 (112 sectors) [83609.713664] btrfs-submit-1(693): WRITE block
61174536 on dm-3 (1024 sectors) [83609.713676] btrfs-submit-1(693):
WRITE block 61175560 on dm-3 (112 sectors) [83609.713760]
btrfs-submit-1(693): WRITE block 71606888 on dm-3 (1024 sectors)
[83609.713772] btrfs-submit-1(693): WRITE block 71607912 on dm-3 (112
sectors) [83609.713856] btrfs-submit-1(693): WRITE block 147055200 on
dm-3 (1024 sectors) [83609.713868] btrfs-submit-1(693): WRITE block
147056224 on dm-3 (112 sectors) [83609.713950] btrfs-submit-1(693):
WRITE block 160459568 on dm-3 (1024 sectors) [83609.713959]
btrfs-submit-1(693): WRITE block 160460592 on dm-3 (112 sectors)
[83609.714026] btrfs-submit-1(693): WRITE block 259004600 on dm-3
(1024 sectors) [83609.714035] btrfs-submit-1(693): WRITE block
259005624 on dm-3 (112 sectors) [83609.714113] btrfs-submit-1(693):
WRITE block 298307424 on dm-3 (1024 sectors) [83609.714120]
btrfs-submit-1(693): WRITE block 298308448 on dm-3 (112 sectors)
[83609.714187] btrfs-submit-1(693): WRITE block 161050528 on dm-3
(1024 sectors) [83609.714196] btrfs-submit-1(693): WRITE block
161051552 on dm-3 (104 sectors) [83609.714262] btrfs-submit-1(693):
WRITE block 303631272 on dm-3 (1024 sectors) [83609.714271]
btrfs-submit-1(693): WRITE block 303632296 on dm-3 (104 sectors)
[83609.714340] btrfs-submit-1(693): WRITE block 304615888 on dm-3
(1024 sectors) [83609.714348] btrfs-submit-1(693): WRITE block
304616912 on dm-3 (104 sectors) [83609.714415] btrfs-submit-1(693):
WRITE block 309079808 on dm-3 (1024 sectors) [83609.714423]
btrfs-submit-1(693): WRITE block 309080832 on dm-3 (104 sectors)
[83609.714496] btrfs-submit-1(693): WRITE block 309876600 on dm-3
(1024 sectors) [83609.714504] btrfs-submit-1(693): WRITE block
309877624 on dm-3 (104 sectors) [83609.714570] btrfs-submit-1(693):
WRITE block 309907552 on dm-3 (1024 sectors) [83609.714579]
btrfs-submit-1(693): WRITE block 309908576 on dm-3 (104 sectors)
[83609.714651] btrfs-submit-1(693): WRITE block 311752792 on dm-3
(1024 sectors) [83609.714660] btrfs-submit-1(693): WRITE block
311753816 on dm-3 (104 sectors) [83609.714752] btrfs-submit-1(693):
WRITE block 311761776 on dm-3 (1024 sectors) [83609.714756]
btrfs-submit-1(693): WRITE block 311762800 on dm-3 (104 sectors)
[83609.714813] btrfs-submit-1(693): WRITE block 356183608 on dm-3
(1024 sectors) [83609.714820] btrfs-submit-1(693): WRITE block
356184632 on dm-3 (96 sectors) [83609.714890] btrfs-submit-1(693):
WRITE block 128392888 on dm-3 (1024 sectors) [83609.714899]
btrfs-submit-1(693): WRITE block 128393912 on dm-3 (96 sectors)
[83609.714968] btrfs-submit-1(693): WRITE block 136567632 on dm-3
(1024 sectors) [83609.714977] btrfs-submit-1(693): WRITE block
136568656 on dm-3 (96 sectors) [83609.715048] btrfs-submit-1(693):
WRITE block 193379384 on dm-3 (1024 sectors) [83609.715063]
btrfs-submit-1(693): WRITE block 193380408 on dm-3 (96 sectors)
[83609.715139] btrfs-submit-1(693): WRITE block 221434792 on dm-3
(1024 sectors) [83609.715147] btrfs-submit-1(693): WRITE block
221435816 on dm-3 (96 sectors) [83609.715245] btrfs-submit-1(693):
WRITE block 241650632 on dm-3 (1024 sectors) [83609.715253]
btrfs-submit-1(693): WRITE block 241651656 on dm-3 (96 sectors)
[83609.715354] btrfs-submit-1(693): WRITE block 312649072 on dm-3
(1024 sectors) [83609.715363] btrfs-submit-1(693): WRITE block
312650096 on dm-3 (96 sectors) [83609.715417] btrfs-submit-1(693):
WRITE block 59835408 on dm-3 (728 sectors) [83609.715443]
btrfs-submit-1(693): WRITE block 59836136 on dm-3 (384 sectors)
[83609.715555] btrfs-submit-1(693): WRITE block 152939864 on dm-3
(1024 sectors) [83609.715562] btrfs-submit-1(693): WRITE block
152940888 on dm-3 (88 sectors) [83609.715635] btrfs-submit-1(693):
WRITE block 297272472 on dm-3 (1024 sectors) [83609.715643]
btrfs-submit-1(693): WRITE block 297273496 on dm-3 (88 sectors)
[83609.715717] btrfs-submit-1(693): WRITE block 299269608 on dm-3
(1024 sectors) [83609.715724] btrfs-submit-1(693): WRITE block
299270632 on dm-3 (88 sectors) [83609.715794] btrfs-submit-1(693):
WRITE block 316572464 on dm-3 (1024 sectors) [83609.715802]
btrfs-submit-1(693): WRITE block 316573488 on dm-3 (88 sectors)
[83609.715871] btrfs-submit-1(693): WRITE block 318037720 on dm-3
(1024 sectors) [83609.715879] btrfs-submit-1(693): WRITE block
318038744 on dm-3 (88 sectors) [83609.715947] btrfs-submit-1(693):
WRITE block 318797760 on dm-3 (1024 sectors) [83609.715955]
btrfs-submit-1(693): WRITE block 318798784 on dm-3 (88 sectors)
[83609.716024] btrfs-submit-1(693): WRITE block 150337048 on dm-3
(1024 sectors) [83609.716032] btrfs-submit-1(693): WRITE block
150338072 on dm-3 (80 sectors) [83609.716109] btrfs-submit-1(693):
WRITE block 205663688 on dm-3 (1024 sectors) [83609.716115]
btrfs-submit-1(693): WRITE block 205664712 on dm-3 (80 sectors)
[83609.716183] btrfs-submit-1(693): WRITE block 218109424 on dm-3
(1024 sectors) [83609.716190] btrfs-submit-1(693): WRITE block
218110448 on dm-3 (80 sectors) [83609.716286] btrfs-submit-1(693):
WRITE block 296758960 on dm-3 (1024 sectors) [83609.716294]
btrfs-submit-1(693): WRITE block 296759984 on dm-3 (80 sectors)
[83609.716397] btrfs-submit-1(693): WRITE block 309847648 on dm-3
(1024 sectors) [83609.716403] btrfs-submit-1(693): WRITE block
309848672 on dm-3 (80 sectors) [83609.716506] btrfs-submit-1(693):
WRITE block 310871592 on dm-3 (1024 sectors) [83609.716512]
btrfs-submit-1(693): WRITE block 310872616 on dm-3 (80 sectors)
[83609.716593] btrfs-submit-1(693): WRITE block 315141576 on dm-3
(1024 sectors) [83609.716600] btrfs-submit-1(693): WRITE block
315142600 on dm-3 (80 sectors) [83609.716667] btrfs-submit-1(693):
WRITE block 317505056 on dm-3 (1024 sectors) [83609.716675]
btrfs-submit-1(693): WRITE block 317506080 on dm-3 (80 sectors)
[83609.716716] btrfs-submit-1(693): WRITE block 80521152 on dm-3 (576
sectors) [83609.716752] btrfs-submit-1(693): WRITE block 80521728 on
dm-3 (520 sectors) [83609.716819] btrfs-submit-1(693): WRITE block
97871544 on dm-3 (1024 sectors) [83609.716826] btrfs-submit-1(693):
WRITE block 97872568 on dm-3 (72 sectors) [83609.716893]
btrfs-submit-1(693): WRITE block 166240792 on dm-3 (1024 sectors)
[83609.716900] btrfs-submit-1(693): WRITE block 166241816 on dm-3 (72
sectors) [83609.716972] btrfs-submit-1(693): WRITE block 212905712 on
dm-3 (1024 sectors) [83609.716981] btrfs-submit-1(693): WRITE block
212906736 on dm-3 (72 sectors) [83609.717043] btrfs-submit-1(693):
WRITE block 247214736 on dm-3 (1024 sectors) [83609.717050]
btrfs-submit-1(693): WRITE block 247215760 on dm-3 (72 sectors)
[83609.717130] btrfs-submit-1(693): WRITE block 314900592 on dm-3
(1024 sectors) [83609.717135] btrfs-submit-1(693): WRITE block
314901616 on dm-3 (72 sectors) [83609.717205] btrfs-submit-1(693):
WRITE block 318577592 on dm-3 (1024 sectors) [83609.717211]
btrfs-submit-1(693): WRITE block 318578616 on dm-3 (72 sectors)
[83609.717292] btrfs-submit-1(693): WRITE block 88802576 on dm-3 (1024
sectors) [83609.717298] btrfs-submit-1(693): WRITE block 88803600 on
dm-3 (64 sectors) [83609.717397] btrfs-submit-1(693): WRITE block
186145536 on dm-3 (1024 sectors) [83609.717404] btrfs-submit-1(693):
WRITE block 186146560 on dm-3 (64 sectors) [83609.717509]
btrfs-submit-1(693): WRITE block 221431208 on dm-3 (1024 sectors)
[83609.717515] btrfs-submit-1(693): WRITE block 221432232 on dm-3 (64
sectors) [83609.717590] btrfs-submit-1(693): WRITE block 246244976 on
dm-3 (1024 sectors) [83609.717597] btrfs-submit-1(693): WRITE block
246246000 on dm-3 (64 sectors) [83609.717670] btrfs-submit-1(693):
WRITE block 308591608 on dm-3 (1024 sectors) [83609.717676]
btrfs-submit-1(693): WRITE block 308592632 on dm-3 (64 sectors)
[83609.717748] btrfs-submit-1(693): WRITE block 309402560 on dm-3
(1024 sectors) [83609.717755] btrfs-submit-1(693): WRITE block
309403584 on dm-3 (64 sectors) [83609.717827] btrfs-submit-1(693):
WRITE block 318731584 on dm-3 (1024 sectors) [83609.717833]
btrfs-submit-1(693): WRITE block 318732608 on dm-3 (64 sectors)
[83609.717907] btrfs-submit-1(693): WRITE block 319101864 on dm-3
(1024 sectors) [83609.717912] btrfs-submit-1(693): WRITE block
319102888 on dm-3 (64 sectors) [83609.717963] btrfs-submit-1(693):
WRITE block 57305544 on dm-3 (664 sectors) [83609.717994]
btrfs-submit-1(693): WRITE block 57306208 on dm-3 (416 sectors)
[83609.718077] btrfs-submit-1(693): WRITE block 63443496 on dm-3 (1024
sectors) [83609.718086] btrfs-submit-1(693): WRITE block 63444520 on
dm-3 (56 sectors) [83609.718154] btrfs-submit-1(693): WRITE block
64846280 on dm-3 (1024 sectors) [83609.718159] btrfs-submit-1(693):
WRITE block 64847304 on dm-3 (56 sectors) [83609.718229]
btrfs-submit-1(693): WRITE block 82688160 on dm-3 (1024 sectors)
[83609.718235] btrfs-submit-1(693): WRITE block 82689184 on dm-3 (56
sectors) [83609.718306] btrfs-submit-1(693): WRITE block 207793344 on
dm-3 (1024 sectors) [83609.718312] btrfs-submit-1(693): WRITE block
207794368 on dm-3 (56 sectors) [83609.718382] btrfs-submit-1(693):
WRITE block 237554360 on dm-3 (1024 sectors) [83609.718388]
btrfs-submit-1(693): WRITE block 237555384 on dm-3 (56 sectors)
[83609.718479] btrfs-submit-1(693): WRITE block 245113288 on dm-3
(1024 sectors) [83609.718485] btrfs-submit-1(693): WRITE block
245114312 on dm-3 (56 sectors) [83609.718590] btrfs-submit-1(693):
WRITE block 39004792 on dm-3 (1024 sectors) [83609.718594]
btrfs-submit-1(693): WRITE block 39005816 on dm-3 (48 sectors)
[83609.718665] btrfs-submit-1(693): WRITE block 101198576 on dm-3
(1024 sectors) [83609.718668] btrfs-submit-1(693): WRITE block
101199600 on dm-3 (48 sectors) [83609.718741] btrfs-submit-1(693):
WRITE block 107696648 on dm-3 (1024 sectors) [83609.718745]
btrfs-submit-1(693): WRITE block 107697672 on dm-3 (48 sectors)
[83609.718888] btrfs-submit-1(693): WRITE block 108305336 on dm-3
(1024 sectors) [83609.718893] btrfs-submit-1(693): WRITE block
108306360 on dm-3 (48 sectors) [83609.718897] btrfs-submit-1(693):
WRITE block 120449832 on dm-3 (1024 sectors) [83609.718900]
btrfs-submit-1(693): WRITE block 120450856 on dm-3 (48 sectors)
[83609.718971] btrfs-submit-1(693): WRITE block 149394360 on dm-3
(1024 sectors) [83609.718975] btrfs-submit-1(693): WRITE block
149395384 on dm-3 (48 sectors) [83609.719045] btrfs-submit-1(693):
WRITE block 207301144 on dm-3 (1024 sectors) [83609.719049]
btrfs-submit-1(693): WRITE block 207302168 on dm-3 (48 sectors)
[83609.719129] btrfs-submit-1(693): WRITE block 221437832 on dm-3
(1024 sectors) [83609.719134] btrfs-submit-1(693): WRITE block
221438856 on dm-3 (48 sectors) [83609.719202] btrfs-submit-1(693):
WRITE block 79843784 on dm-3 (992 sectors) [83609.719208]
btrfs-submit-1(693): WRITE block 79844776 on dm-3 (72 sectors)
[83609.719276] btrfs-submit-1(693): WRITE block 112544232 on dm-3
(1024 sectors) [83609.719280] btrfs-submit-1(693): WRITE block
112545256 on dm-3 (40 sectors) [83609.719349] btrfs-submit-1(693):
WRITE block 173165832 on dm-3 (1024 sectors) [83609.719353]
btrfs-submit-1(693): WRITE block 173166856 on dm-3 (40 sectors)
[83609.719456] btrfs-submit-1(693): WRITE block 218033968 on dm-3
(1024 sectors) [83609.719460] btrfs-submit-1(693): WRITE block
218034992 on dm-3 (40 sectors) [83609.719576] btrfs-submit-1(693):
WRITE block 221449152 on dm-3 (1024 sectors) [83609.719581]
btrfs-submit-1(693): WRITE block 221450176 on dm-3 (40 sectors)
[83609.719613] btrfs-submit-1(693): WRITE block 245626896 on dm-3
(1024 sectors) [83609.719617] btrfs-submit-1(693): WRITE block
245627920 on dm-3 (40 sectors) [83609.719685] btrfs-submit-1(693):
WRITE block 246111984 on dm-3 (1024 sectors) [83609.719689]
btrfs-submit-1(693): WRITE block 246113008 on dm-3 (40 sectors)
[83609.719761] btrfs-submit-1(693): WRITE block 249906192 on dm-3
(1024 sectors) [83609.719765] btrfs-submit-1(693): WRITE block
249907216 on dm-3 (40 sectors) [83609.719838] btrfs-submit-1(693):
WRITE block 333639032 on dm-3 (1024 sectors) [83609.719844]
btrfs-submit-1(693): WRITE block 333640056 on dm-3 (32 sectors)
[83609.719916] btrfs-submit-1(693): WRITE block 58187936 on dm-3 (1024
sectors) [83609.719919] btrfs-submit-1(693): WRITE block 58188960 on
dm-3 (32 sectors) [83609.719991] btrfs-submit-1(693): WRITE block
99306344 on dm-3 (1024 sectors) [83609.719996] btrfs-submit-1(693):
WRITE block 99307368 on dm-3 (32 sectors) [83609.720075]
btrfs-submit-1(693): WRITE block 101003824 on dm-3 (1024 sectors)
[83609.720084] btrfs-submit-1(693): WRITE block 101004848 on dm-3 (32
sectors) [83609.720146] btrfs-submit-1(693): WRITE block 162746360 on
dm-3 (1024 sectors) [83609.720149] btrfs-submit-1(693): WRITE block
162747384 on dm-3 (32 sectors) [83609.720216] btrfs-submit-1(693):
WRITE block 168880992 on dm-3 (1024 sectors) [83609.720221]
btrfs-submit-1(693): WRITE block 168882016 on dm-3 (32 sectors)
[83609.720286] btrfs-submit-1(693): WRITE block 233394344 on dm-3
(1024 sectors) [83609.720291] btrfs-submit-1(693): WRITE block
233395368 on dm-3 (32 sectors) [83609.720367] btrfs-submit-1(693):
WRITE block 83378864 on dm-3 (1024 sectors) [83609.720371]
btrfs-submit-1(693): WRITE block 83379888 on dm-3 (24 sectors)
[83609.720407] btrfs-submit-1(693): WRITE block 87030744 on dm-3 (504
sectors) [83609.720450] btrfs-submit-1(693): WRITE block 87031248 on
dm-3 (544 sectors) [83609.720580] btrfs-submit-1(693): WRITE block
94793800 on dm-3 (1024 sectors) [83609.720583] btrfs-submit-1(693):
WRITE block 94794824 on dm-3 (24 sectors) [83609.720657]
btrfs-submit-1(693): WRITE block 168946320 on dm-3 (1024 sectors)
[83609.720661] btrfs-submit-1(693): WRITE block 168947344 on dm-3 (24
sectors) [83609.720728] btrfs-submit-1(693): WRITE block 173302240 on
dm-3 (1024 sectors) [83609.720731] btrfs-submit-1(693): WRITE block
173303264 on dm-3 (24 sectors) [83609.720800] btrfs-submit-1(693):
WRITE block 245279544 on dm-3 (1024 sectors) [83609.720803]
btrfs-submit-1(693): WRITE block 245280568 on dm-3 (24 sectors)
[83609.720869] btrfs-submit-1(693): WRITE block 245437848 on dm-3
(1024 sectors) [83609.720874] btrfs-submit-1(693): WRITE block
245438872 on dm-3 (24 sectors) [83609.720936] btrfs-submit-1(693):
WRITE block 283271944 on dm-3 (1024 sectors) [83609.720940]
btrfs-submit-1(693): WRITE block 283272968 on dm-3 (24 sectors)
[83609.721005] btrfs-submit-1(693): WRITE block 52564368 on dm-3 (1024
sectors) [83609.721008] btrfs-submit-1(693): WRITE block 52565392 on
dm-3 (16 sectors) [83609.721080] btrfs-submit-1(693): WRITE block
56762744 on dm-3 (1024 sectors) [83609.721087] btrfs-submit-1(693):
WRITE block 56763768 on dm-3 (16 sectors) [83609.721147]
btrfs-submit-1(693): WRITE block 57621752 on dm-3 (1024 sectors)
[83609.721151] btrfs-submit-1(693): WRITE block 57622776 on dm-3 (16
sectors) [83609.721244] btrfs-submit-1(693): WRITE block 140552336 on
dm-3 (1024 sectors) [83609.721249] btrfs-submit-1(693): WRITE block
140553360 on dm-3 (16 sectors) [83609.721347] btrfs-submit-1(693):
WRITE block 143090800 on dm-3 (1024 sectors) [83609.721351]
btrfs-submit-1(693): WRITE block 143091824 on dm-3 (16 sectors)
[83609.721457] btrfs-submit-1(693): WRITE block 161147200 on dm-3
(1024 sectors) [83609.721461] btrfs-submit-1(693): WRITE block
161148224 on dm-3 (16 sectors) [83609.721549] btrfs-submit-1(693):
WRITE block 166659624 on dm-3 (1024 sectors) [83609.721554]
btrfs-submit-1(693): WRITE block 166660648 on dm-3 (16 sectors)
[83609.721624] btrfs-submit-1(693): WRITE block 187310856 on dm-3
(1024 sectors) [83609.721629] btrfs-submit-1(693): WRITE block
187311880 on dm-3 (16 sectors) [83609.721697] btrfs-submit-1(693):
WRITE block 66850560 on dm-3 (1024 sectors) [83609.721701]
btrfs-submit-1(693): WRITE block 66851584 on dm-3 (8 sectors)
[83609.721720] btrfs-submit-1(693): WRITE block 134127312 on dm-3 (280
sectors) [83609.721770] btrfs-submit-1(693): WRITE block 134127592 on
dm-3 (752 sectors) [83609.721851] btrfs-submit-1(693): WRITE block
170391816 on dm-3 (1024 sectors) [83609.721854] btrfs-submit-1(693):
WRITE block 170392840 on dm-3 (8 sectors) [83609.721928]
btrfs-submit-1(693): WRITE block 179015256 on dm-3 (1024 sectors)
[83609.721933] btrfs-submit-1(693): WRITE block 179016280 on dm-3 (8
sectors) [83609.722005] btrfs-submit-1(693): WRITE block 184130264 on
dm-3 (1024 sectors) [83609.722010] btrfs-submit-1(693): WRITE block
184131288 on dm-3 (8 sectors) [83609.722094] btrfs-submit-1(693):
WRITE block 197246832 on dm-3 (1024 sectors) [83609.722100]
btrfs-submit-1(693): WRITE block 197247856 on dm-3 (8 sectors)
[83609.722181] btrfs-submit-1(693): WRITE block 203632192 on dm-3
(1024 sectors) [83609.722184] btrfs-submit-1(693): WRITE block
203633216 on dm-3 (8 sectors) [83609.722283] btrfs-submit-1(693):
WRITE block 204200424 on dm-3 (1024 sectors) [83609.722287]
btrfs-submit-1(693): WRITE block 204201448 on dm-3 (8 sectors)
[83609.722392] btrfs-submit-1(693): WRITE block 354079160 on dm-3
(1024 sectors) [83609.722498] btrfs-submit-1(693): WRITE block
354140592 on dm-3 (1024 sectors) [83609.722575] btrfs-submit-1(693):
WRITE block 354154032 on dm-3 (1024 sectors) [83609.722650]
btrfs-submit-1(693): WRITE block 354165528 on dm-3 (1024 sectors)
[83609.722728] btrfs-submit-1(693): WRITE block 38732680 on dm-3 (1024
sectors) [83609.722806] btrfs-submit-1(693): WRITE block 58442680 on
dm-3 (1024 sectors) [83609.722879] btrfs-submit-1(693): WRITE block
88814208 on dm-3 (1024 sectors) [83609.722951] btrfs-submit-1(693):
WRITE block 97942744 on dm-3 (1024 sectors) [83609.723028]
btrfs-submit-1(693): WRITE block 99360224 on dm-3 (1016 sectors)
[83609.723052] btrfs-submit-1(693): WRITE block 116907032 on dm-3 (312
sectors) [83609.723112] btrfs-submit-1(693): WRITE block 116907344 on
dm-3 (704 sectors) [83609.723196] btrfs-submit-1(693): WRITE block
117911240 on dm-3 (1016 sectors) [83609.723297] btrfs-submit-1(693):
WRITE block 141362464 on dm-3 (1016 sectors) [83609.723381]
btrfs-submit-1(693): WRITE block 142563384 on dm-3 (1016 sectors)
[83609.723456] btrfs-submit-1(693): WRITE block 152446096 on dm-3
(1016 sectors) [83609.723528] btrfs-submit-1(693): WRITE block
175676648 on dm-3 (1016 sectors) [83609.723599] btrfs-submit-1(693):
WRITE block 199305032 on dm-3 (1016 sectors) [83609.723668]
btrfs-submit-1(693): WRITE block 108199368 on dm-3 (1008 sectors)
[83609.723741] btrfs-submit-1(693): WRITE block 160229048 on dm-3
(1008 sectors) [83609.723813] btrfs-submit-1(693): WRITE block
168636808 on dm-3 (1008 sectors) [83609.723880] btrfs-submit-1(693):
WRITE block 213211816 on dm-3 (1008 sectors) [83609.723947]
btrfs-submit-1(693): WRITE block 216119504 on dm-3 (1008 sectors)
[83609.724014] btrfs-submit-1(693): WRITE block 220250896 on dm-3
(1008 sectors) [83609.724092] btrfs-submit-1(693): WRITE block
233123520 on dm-3 (1008 sectors) [83609.724161] btrfs-submit-1(693):
WRITE block 233991624 on dm-3 (1008 sectors) [83609.724239]
btrfs-submit-1(693): WRITE block 58257208 on dm-3 (1000 sectors)
[83609.724280] btrfs-submit-1(693): WRITE block 106595624 on dm-3 (600
sectors) [83609.724310] btrfs-submit-1(693): WRITE block 106596224 on
dm-3 (400 sectors) [83609.724439] btrfs-submit-1(693): WRITE block
122377688 on dm-3 (1000 sectors) [83609.724508] btrfs-submit-1(693):
WRITE block 143951696 on dm-3 (1000 sectors) [83609.724577]
btrfs-submit-1(693): WRITE block 145205360 on dm-3 (1000 sectors)
[83609.724644] btrfs-submit-1(693): WRITE block 179677240 on dm-3
(1000 sectors) [83609.724715] btrfs-submit-1(693): WRITE block
194209992 on dm-3 (1000 sectors) [83609.724790] btrfs-submit-1(693):
WRITE block 210839864 on dm-3 (1000 sectors) [83609.724861]
btrfs-submit-1(693): WRITE block 93794728 on dm-3 (992 sectors)
[83609.724937] btrfs-submit-1(693): WRITE block 99192704 on dm-3 (992
sectors) [83609.725003] btrfs-submit-1(693): WRITE block 116690176 on
dm-3 (992 sectors) [83609.725077] btrfs-submit-1(693): WRITE block
221454584 on dm-3 (992 sectors) [83609.725144] btrfs-submit-1(693):
WRITE block 232745472 on dm-3 (992 sectors) [83609.725220]
btrfs-submit-1(693): WRITE block 233967960 on dm-3 (992 sectors)
[83609.725318] btrfs-submit-1(693): WRITE block 234078224 on dm-3 (992
sectors) [83609.725389] btrfs-submit-1(693): WRITE block 238618408 on
dm-3 (992 sectors) [83609.725455] btrfs-submit-1(693): WRITE block
240994160 on dm-3 (992 sectors) [83609.725521] btrfs-submit-1(693):
WRITE block 38662560 on dm-3 (984 sectors) [83609.725533]
btrfs-submit-1(693): WRITE block 77945568 on dm-3 (152 sectors)
[83609.725589] btrfs-submit-1(693): WRITE block 77945720 on dm-3 (832
sectors) [83609.725654] btrfs-submit-1(693): WRITE block 136543656 on
dm-3 (984 sectors) [83609.725718] btrfs-submit-1(693): WRITE block
142355872 on dm-3 (984 sectors) [83609.725784] btrfs-submit-1(693):
WRITE block 164967760 on dm-3 (984 sectors) [83609.725850]
btrfs-submit-1(693): WRITE block 168384696 on dm-3 (984 sectors)
[83609.725916] btrfs-submit-1(693): WRITE block 203179592 on dm-3 (984
sectors) [83609.725981] btrfs-submit-1(693): WRITE block 214657728 on
dm-3 (984 sectors) [83609.726045] btrfs-submit-1(693): WRITE block
98053096 on dm-3 (976 sectors) [83609.726114] btrfs-submit-1(693):
WRITE block 233079288 on dm-3 (976 sectors) [83609.726176]
btrfs-submit-1(693): WRITE block 234305976 on dm-3 (976 sectors)
[83609.726252] btrfs-submit-1(693): WRITE block 235874592 on dm-3 (976
sectors) [83609.726339] btrfs-submit-1(693): WRITE block 241085032 on
dm-3 (976 sectors) [83609.726429] btrfs-submit-1(693): WRITE block
241269992 on dm-3 (976 sectors) [83609.726492] btrfs-submit-1(693):
WRITE block 241367656 on dm-3 (976 sectors) [83609.726556]
btrfs-submit-1(693): WRITE block 241372680 on dm-3 (976 sectors)
[83609.726626] btrfs-submit-1(693): WRITE block 67659536 on dm-3 (968
sectors) [83609.726693] btrfs-submit-1(693): WRITE block 89721200 on
dm-3 (952 sectors) [83609.726698] btrfs-submit-1(693): WRITE block
89722152 on dm-3 (16 sectors) [83609.726762] btrfs-submit-1(693):
WRITE block 112577160 on dm-3 (968 sectors) [83609.726827]
btrfs-submit-1(693): WRITE block 175221376 on dm-3 (968 sectors)
[83609.726891] btrfs-submit-1(693): WRITE block 241374008 on dm-3 (968
sectors) [83609.726957] btrfs-submit-1(693): WRITE block 241574200 on
dm-3 (968 sectors) [83609.727021] btrfs-submit-1(693): WRITE block
241831744 on dm-3 (968 sectors) [83609.727096] btrfs-submit-1(693):
WRITE block 243918560 on dm-3 (968 sectors) [83609.727162]
btrfs-submit-1(693): WRITE block 244784088 on dm-3 (968 sectors)
[83609.727225] btrfs-submit-1(693): WRITE block 48244696 on dm-3 (960
sectors) [83609.727289] btrfs-submit-1(693): WRITE block 239757384 on
dm-3 (960 sectors) [83609.727374] btrfs-submit-1(693): WRITE block
245247008 on dm-3 (960 sectors) [83609.727445] btrfs-submit-1(693):
WRITE block 245332608 on dm-3 (960 sectors) [83609.727509]
btrfs-submit-1(693): WRITE block 245473784 on dm-3 (960 sectors)
[83609.727573] btrfs-submit-1(693): WRITE block 245495632 on dm-3 (960
sectors) [83609.727637] btrfs-submit-1(693): WRITE block 245695728 on
dm-3 (960 sectors) [83609.727701] btrfs-submit-1(693): WRITE block
245852272 on dm-3 (960 sectors) [83609.727768] btrfs-submit-1(693):
WRITE block 58130336 on dm-3 (952 sectors) [83609.727838]
btrfs-submit-1(693): WRITE block 108117032 on dm-3 (952 sectors)
[83609.727847] btrfs-submit-1(693): WRITE block 145000008 on dm-3 (88
sectors) [83609.727909] btrfs-submit-1(693): WRITE block 145000096 on
dm-3 (864 sectors) [83609.727976] btrfs-submit-1(693): WRITE block
147667688 on dm-3 (952 sectors) [83609.728042] btrfs-submit-1(693):
WRITE block 166043928 on dm-3 (952 sectors) [83609.728116]
btrfs-submit-1(693): WRITE block 175778056 on dm-3 (952 sectors)
[83609.728179] btrfs-submit-1(693): WRITE block 184946312 on dm-3 (952
sectors) [83609.728244] btrfs-submit-1(693): WRITE block 211903240 on
dm-3 (952 sectors) [83609.728308] btrfs-submit-1(693): WRITE block
237353440 on dm-3 (952 sectors) [83609.728385] btrfs-submit-1(693):
WRITE block 56983488 on dm-3 (944 sectors) [83609.728454]
btrfs-submit-1(693): WRITE block 83580360 on dm-3 (944 sectors)
[83609.728519] btrfs-submit-1(693): WRITE block 101102232 on dm-3 (944
sectors) [83609.728581] btrfs-submit-1(693): WRITE block 147267672 on
dm-3 (944 sectors) [83609.728645] btrfs-submit-1(693): WRITE block
169141040 on dm-3 (944 sectors) [83609.728707] btrfs-submit-1(693):
WRITE block 240967424 on dm-3 (944 sectors) [83609.728771]
btrfs-submit-1(693): WRITE block 241645832 on dm-3 (944 sectors)
[83609.728834] btrfs-submit-1(693): WRITE block 243950608 on dm-3 (944
sectors) [83609.728897] btrfs-submit-1(693): WRITE block 245511048 on
dm-3 (944 sectors) [83609.728961] btrfs-submit-1(693): WRITE block
46641544 on dm-3 (936 sectors) [83609.728998] btrfs-submit-1(693):
WRITE block 58829848 on dm-3 (456 sectors) [83609.729033]
btrfs-submit-1(693): WRITE block 58830304 on dm-3 (480 sectors)
[83609.729106] btrfs-submit-1(693): WRITE block 106648136 on dm-3 (936
sectors) [83609.729170] btrfs-submit-1(693): WRITE block 112849208 on
dm-3 (936 sectors) [83609.729234] btrfs-submit-1(693): WRITE block
135846272 on dm-3 (936 sectors) [83609.729326] btrfs-submit-1(693):
WRITE block 138319568 on dm-3 (936 sectors) [83609.729417]
btrfs-submit-1(693): WRITE block 150333584 on dm-3 (936 sectors)
[83609.729481] btrfs-submit-1(693): WRITE block 241395528 on dm-3 (936
sectors) [83609.729544] btrfs-submit-1(693): WRITE block 86183936 on
dm-3 (928 sectors) [83609.729609] btrfs-submit-1(693): WRITE block
107700504 on dm-3 (928 sectors) [83609.729674] btrfs-submit-1(693):
WRITE block 116269672 on dm-3 (928 sectors) [83609.729738]
btrfs-submit-1(693): WRITE block 118217792 on dm-3 (928 sectors)
[83609.729802] btrfs-submit-1(693): WRITE block 136387680 on dm-3 (928
sectors) [83609.729867] btrfs-submit-1(693): WRITE block 141995120 on
dm-3 (928 sectors) [83609.729933] btrfs-submit-1(693): WRITE block
147196392 on dm-3 (928 sectors) [83609.729998] btrfs-submit-1(693):
WRITE block 168742440 on dm-3 (928 sectors) [83609.730072]
btrfs-submit-1(693): WRITE block 245267616 on dm-3 (928 sectors)
[83609.730141] btrfs-submit-1(693): WRITE block 46241792 on dm-3 (920
sectors) [83609.730204] btrfs-submit-1(693): WRITE block 58711208 on
dm-3 (920 sectors) [83609.730218] btrfs-submit-1(693): WRITE block
97897488 on dm-3 (176 sectors) [83609.730270] btrfs-submit-1(693):
WRITE block 97897664 on dm-3 (744 sectors) [83609.730364]
btrfs-submit-1(693): WRITE block 106023912 on dm-3 (920 sectors)
[83609.730436] btrfs-submit-1(693): WRITE block 138296552 on dm-3 (920
sectors) [83609.730505] btrfs-submit-1(693): WRITE block 145156480 on
dm-3 (920 sectors) [83609.730570] btrfs-submit-1(693): WRITE block
162173712 on dm-3 (920 sectors) [83609.730635] btrfs-submit-1(693):
WRITE block 162256920 on dm-3 (920 sectors) [83609.730709]
btrfs-submit-1(693): WRITE block 186710624 on dm-3 (920 sectors)
[83609.730776] btrfs-submit-1(693): WRITE block 356400568 on dm-3
(1024 sectors) [83609.730832] btrfs-submit-1(693): WRITE block
356401592 on dm-3 (808 sectors) [83609.730898] btrfs-submit-1(693):
WRITE block 55822008 on dm-3 (912 sectors) [83609.730962]
btrfs-submit-1(693): WRITE block 93783608 on dm-3 (912 sectors)
[83609.731028] btrfs-submit-1(693): WRITE block 142365200 on dm-3 (912
sectors) [83609.731098] btrfs-submit-1(693): WRITE block 147713632 on
dm-3 (912 sectors) [83609.731162] btrfs-submit-1(693): WRITE block
147978736 on dm-3 (912 sectors) [83609.731226] btrfs-submit-1(693):
WRITE block 168079792 on dm-3 (912 sectors) [83609.731288]
btrfs-submit-1(693): WRITE block 175975360 on dm-3 (912 sectors)
[83609.731350] btrfs-submit-1(693): WRITE block 76279040 on dm-3 (904
sectors) [83609.731412] btrfs-submit-1(693): WRITE block 97916680 on
dm-3 (904 sectors) [83609.731426] btrfs-submit-1(693): WRITE block
108112032 on dm-3 (176 sectors) [83609.731476] btrfs-submit-1(693):
WRITE block 108112208 on dm-3 (728 sectors) [83609.731538]
btrfs-submit-1(693): WRITE block 113507360 on dm-3 (904 sectors)
[83609.731601] btrfs-submit-1(693): WRITE block 142465368 on dm-3 (904
sectors) [83609.731664] btrfs-submit-1(693): WRITE block 142630968 on
dm-3 (904 sectors) [83609.731726] btrfs-submit-1(693): WRITE block
143499216 on dm-3 (904 sectors) [83609.731789] btrfs-submit-1(693):
WRITE block 183729192 on dm-3 (904 sectors) [83609.731850]
btrfs-submit-1(693): WRITE block 199760080 on dm-3 (904 sectors)
[83609.731912] btrfs-submit-1(693): WRITE block 321839016 on dm-3 (896
sectors) [83609.731973] btrfs-submit-1(693): WRITE block 321858632 on
dm-3 (896 sectors) [83609.732037] btrfs-submit-1(693): WRITE block
48550936 on dm-3 (896 sectors) [83609.732110] btrfs-submit-1(693):
WRITE block 76671440 on dm-3 (896 sectors) [83609.732170]
btrfs-submit-1(693): WRITE block 99317712 on dm-3 (896 sectors)
[83609.732231] btrfs-submit-1(693): WRITE block 113475064 on dm-3 (896
sectors) [83609.732291] btrfs-submit-1(693): WRITE block 139148504 on
dm-3 (896 sectors) [83609.732349] btrfs-submit-1(693): WRITE block
140323568 on dm-3 (896 sectors) [83609.732432] btrfs-submit-1(693):
WRITE block 166860384 on dm-3 (896 sectors) [83609.732496]
btrfs-submit-1(693): WRITE block 57406408 on dm-3 (888 sectors)
[83609.732559] btrfs-submit-1(693): WRITE block 135647104 on dm-3 (888
sectors) [83609.732592] btrfs-submit-1(693): WRITE block 141930272 on
dm-3 (472 sectors) [83609.732621] btrfs-submit-1(693): WRITE block
141930744 on dm-3 (416 sectors) [83609.732681] btrfs-submit-1(693):
WRITE block 142011536 on dm-3 (888 sectors) [83609.732740]
btrfs-submit-1(693): WRITE block 142167304 on dm-3 (888 sectors)
[83609.732800] btrfs-submit-1(693): WRITE block 146066464 on dm-3 (888
sectors) [83609.732860] btrfs-submit-1(693): WRITE block 146485752 on
dm-3 (888 sectors) [83609.732918] btrfs-submit-1(693): WRITE block
146906032 on dm-3 (888 sectors) [83609.732976] btrfs-submit-1(693):
WRITE block 167581048 on dm-3 (888 sectors) [83609.733034]
btrfs-submit-1(693): WRITE block 183537008 on dm-3 (888 sectors)
[83609.733102] btrfs-submit-1(693): WRITE block 82997360 on dm-3 (880
sectors) [83609.733159] btrfs-submit-1(693): WRITE block 135620744 on
dm-3 (880 sectors) [83609.733217] btrfs-submit-1(693): WRITE block
141064248 on dm-3 (880 sectors) [83609.733275] btrfs-submit-1(693):
WRITE block 145105936 on dm-3 (880 sectors) [83609.733350]
btrfs-submit-1(693): WRITE block 146653712 on dm-3 (880 sectors)
[83609.733429] btrfs-submit-1(693): WRITE block 147025048 on dm-3 (880
sectors) [83609.733488] btrfs-submit-1(693): WRITE block 149859592 on
dm-3 (880 sectors) [83609.733547] btrfs-submit-1(693): WRITE block
161339440 on dm-3 (880 sectors) [83609.733606] btrfs-submit-1(693):
WRITE block 161389336 on dm-3 (880 sectors) [83609.733663]
btrfs-submit-1(693): WRITE block 141887704 on dm-3 (872 sectors)
[83609.733721] btrfs-submit-1(693): WRITE block 141900464 on dm-3 (872
sectors) [83609.733734] btrfs-submit-1(693): WRITE block 150626376 on
dm-3 (168 sectors) [83609.733780] btrfs-submit-1(693): WRITE block
150626544 on dm-3 (704 sectors) [83609.733838] btrfs-submit-1(693):
WRITE block 165871888 on dm-3 (872 sectors) [83609.733895]
btrfs-submit-1(693): WRITE block 174109728 on dm-3 (872 sectors)
[83609.733952] btrfs-submit-1(693): WRITE block 183990808 on dm-3 (872
sectors) [83609.734008] btrfs-submit-1(693): WRITE block 188644904 on
dm-3 (872 sectors) [83609.734072] btrfs-submit-1(693): WRITE block
199875120 on dm-3 (872 sectors) [83609.734128] btrfs-submit-1(693):
WRITE block 200716264 on dm-3 (872 sectors) [83609.734185]
btrfs-submit-1(693): WRITE block 48706128 on dm-3 (864 sectors)
[83609.734241] btrfs-submit-1(693): WRITE block 97994912 on dm-3 (864
sectors) [83609.734331] btrfs-submit-1(693): WRITE block 106599056 on
dm-3 (864 sectors) [83609.734413] btrfs-submit-1(693): WRITE block
122302488 on dm-3 (864 sectors) [83609.734476] btrfs-submit-1(693):
WRITE block 141206664 on dm-3 (864 sectors) [83609.734538]
btrfs-submit-1(693): WRITE block 141571512 on dm-3 (864 sectors)
[83609.734600] btrfs-submit-1(693): WRITE block 152362568 on dm-3 (864
sectors) [83609.734658] btrfs-submit-1(693): WRITE block 203909216 on
dm-3 (864 sectors) [83609.734721] btrfs-submit-1(693): WRITE block
212703312 on dm-3 (864 sectors) [83609.734779] btrfs-submit-1(693):
WRITE block 218100040 on dm-3 (864 sectors) [83609.734837]
btrfs-submit-1(693): WRITE block 97867936 on dm-3 (856 sectors)
[83609.734897] btrfs-submit-1(693): WRITE block 118862112 on dm-3 (856
sectors) [83609.734909] btrfs-submit-1(693): WRITE block 141388712 on
dm-3 (176 sectors) [83609.734954] btrfs-submit-1(693): WRITE block
141388888 on dm-3 (680 sectors) [83609.735010] btrfs-submit-1(693):
WRITE block 160531432 on dm-3 (856 sectors) [83609.735093]
btrfs-submit-1(693): WRITE block 220768952 on dm-3 (856 sectors)
[83609.735128] btrfs-submit-1(693): WRITE block 221432984 on dm-3 (856
sectors) [83609.735198] btrfs-submit-1(693): WRITE block 229951648 on
dm-3 (856 sectors) [83609.735284] btrfs-submit-1(693): WRITE block
232344600 on dm-3 (856 sectors) [83609.735366] btrfs-submit-1(693):
WRITE block 232655368 on dm-3 (856 sectors) [83609.735430]
btrfs-submit-1(693): WRITE block 44633184 on dm-3 (848 sectors)
[83609.735491] btrfs-submit-1(693): WRITE block 118056864 on dm-3 (848
sectors) [83609.735552] btrfs-submit-1(693): WRITE block 141372136 on
dm-3 (848 sectors) [83609.735611] btrfs-submit-1(693): WRITE block
191747816 on dm-3 (848 sectors) [83609.735672] btrfs-submit-1(693):
WRITE block 212702448 on dm-3 (848 sectors) [83609.735732]
btrfs-submit-1(693): WRITE block 216452464 on dm-3 (848 sectors)
[83609.735795] btrfs-submit-1(693): WRITE block 239764408 on dm-3 (848
sectors) [83609.735858] btrfs-submit-1(693): WRITE block 240384384 on
dm-3 (848 sectors) [83609.735916] btrfs-submit-1(693): WRITE block
241066944 on dm-3 (848 sectors) [83609.735977] btrfs-submit-1(693):
WRITE block 241098864 on dm-3 (848 sectors) [83609.736037]
btrfs-submit-1(693): WRITE block 41093376 on dm-3 (840 sectors)
[83609.736102] btrfs-submit-1(693): WRITE block 41193360 on dm-3 (840
sectors) [83609.736135] btrfs-submit-1(693): WRITE block 135583576 on
dm-3 (488 sectors) [83609.736161] btrfs-submit-1(693): WRITE block
135584064 on dm-3 (352 sectors) [83609.736261] btrfs-submit-1(693):
WRITE block 141121944 on dm-3 (840 sectors) [83609.736345]
btrfs-submit-1(693): WRITE block 168125448 on dm-3 (840 sectors)
[83609.736418] btrfs-submit-1(693): WRITE block 193273016 on dm-3 (840
sectors) [83609.736478] btrfs-submit-1(693): WRITE block 212586224 on
dm-3 (840 sectors) [83609.736537] btrfs-submit-1(693): WRITE block
234081584 on dm-3 (840 sectors) [83609.736599] btrfs-submit-1(693):
WRITE block 236077272 on dm-3 (840 sectors) [83609.736656]
btrfs-submit-1(693): WRITE block 236346560 on dm-3 (840 sectors)
[83609.736716] btrfs-submit-1(693): WRITE block 326462800 on dm-3 (832
sectors) [83609.736770] btrfs-submit-1(693): WRITE block 326475416 on
dm-3 (832 sectors) [83609.736826] btrfs-submit-1(693): WRITE block
326476592 on dm-3 (832 sectors) [83609.736882] btrfs-submit-1(693):
WRITE block 326511576 on dm-3 (832 sectors) [83609.736937]
btrfs-submit-1(693): WRITE block 42259576 on dm-3 (832 sectors)
[83609.736991] btrfs-submit-1(693): WRITE block 133266656 on dm-3 (832
sectors) [83609.737050] btrfs-submit-1(693): WRITE block 141056664 on
dm-3 (832 sectors) [83609.737112] btrfs-submit-1(693): WRITE block
141084688 on dm-3 (832 sectors) [83609.737192] btrfs-submit-1(693):
WRITE block 141099872 on dm-3 (832 sectors) [83609.737275]
btrfs-submit-1(693): WRITE block 145072056 on dm-3 (832 sectors)
[83609.737356] btrfs-submit-1(693): WRITE block 63682968 on dm-3 (824
sectors) [83609.737423] btrfs-submit-1(693): WRITE block 98040456 on
dm-3 (824 sectors) [83609.737442] btrfs-submit-1(693): WRITE block
114103840 on dm-3 (264 sectors) [83609.737479] btrfs-submit-1(693):
WRITE block 114104104 on dm-3 (560 sectors) [83609.737544]
btrfs-submit-1(693): WRITE block 123971136 on dm-3 (824 sectors)
[83609.737599] btrfs-submit-1(693): WRITE block 140061512 on dm-3 (824
sectors) [83609.737652] btrfs-submit-1(693): WRITE block 140508536 on
dm-3 (824 sectors) [83609.737705] btrfs-submit-1(693): WRITE block
140872432 on dm-3 (824 sectors) [83609.737759] btrfs-submit-1(693):
WRITE block 168134448 on dm-3 (824 sectors) [83609.737812]
btrfs-submit-1(693): WRITE block 168176088 on dm-3 (824 sectors)
[83609.737864] btrfs-submit-1(693): WRITE block 79856720 on dm-3 (816
sectors) [83609.737918] btrfs-submit-1(693): WRITE block 93890848 on
dm-3 (816 sectors) [83609.737970] btrfs-submit-1(693): WRITE block
118041736 on dm-3 (816 sectors) [83609.738021] btrfs-submit-1(693):
WRITE block 153297856 on dm-3 (816 sectors) [83609.738080]
btrfs-submit-1(693): WRITE block 153489528 on dm-3 (816 sectors)
[83609.738130] btrfs-submit-1(693): WRITE block 172044272 on dm-3 (816
sectors) [83609.738197] btrfs-submit-1(693): WRITE block 182352664 on
dm-3 (816 sectors) [83609.738273] btrfs-submit-1(693): WRITE block
182365552 on dm-3 (816 sectors) [83609.738349] btrfs-submit-1(693):
WRITE block 188871312 on dm-3 (816 sectors) [83609.738428]
btrfs-submit-1(693): WRITE block 199186992 on dm-3 (816 sectors)
[83609.738486] btrfs-submit-1(693): WRITE block 199961776 on dm-3 (816
sectors) [83609.738542] btrfs-submit-1(693): WRITE block 53288152 on
dm-3 (808 sectors) [83609.738596] btrfs-submit-1(693): WRITE block
83022912 on dm-3 (808 sectors) [83609.738621] btrfs-submit-1(693):
WRITE block 90867160 on dm-3 (368 sectors) [83609.738650]
btrfs-submit-1(693): WRITE block 90867528 on dm-3 (440 sectors)
[83609.738710] btrfs-submit-1(693): WRITE block 113815920 on dm-3 (808
sectors) [83609.738761] btrfs-submit-1(693): WRITE block 138345840 on
dm-3 (808 sectors) [83609.738816] btrfs-submit-1(693): WRITE block
153431280 on dm-3 (808 sectors) [83609.738871] btrfs-submit-1(693):
WRITE block 153465600 on dm-3 (808 sectors) [83609.738928]
btrfs-submit-1(693): WRITE block 168372032 on dm-3 (808 sectors)
[83609.738982] btrfs-submit-1(693): WRITE block 169297688 on dm-3 (808
sectors) [83609.739041] btrfs-submit-1(693): WRITE block 175222400 on
dm-3 (808 sectors) [83609.739107] btrfs-submit-1(693): WRITE block
346124920 on dm-3 (800 sectors) [83609.739181] btrfs-submit-1(693):
WRITE block 346143312 on dm-3 (800 sectors) [83609.739260]
btrfs-submit-1(693): WRITE block 346208184 on dm-3 (800 sectors)
[83609.739342] btrfs-submit-1(693): WRITE block 346213496 on dm-3 (800
sectors) [83609.739407] btrfs-submit-1(693): WRITE block 360799288 on
dm-3 (800 sectors) [83609.739465] btrfs-submit-1(693): WRITE block
360800240 on dm-3 (800 sectors) [83609.739524] btrfs-submit-1(693):
WRITE block 360856504 on dm-3 (800 sectors) [83609.739580]
btrfs-submit-1(693): WRITE block 360893952 on dm-3 (800 sectors)
[83609.739639] btrfs-submit-1(693): WRITE block 360905864 on dm-3 (800
sectors) [83609.739696] btrfs-submit-1(693): WRITE block 62080288 on
dm-3 (800 sectors) [83609.739748] btrfs-submit-1(693): WRITE block
60889584 on dm-3 (792 sectors) [83609.739807] btrfs-submit-1(693):
WRITE block 62980648 on dm-3 (792 sectors) [83609.739862]
btrfs-submit-1(693): WRITE block 72562536 on dm-3 (784 sectors)
[83609.739865] btrfs-submit-1(693): WRITE block 72563320 on dm-3 (8
sectors) [83609.739923] btrfs-submit-1(693): WRITE block 81859264 on
dm-3 (792 sectors) [83609.739977] btrfs-submit-1(693): WRITE block
86182664 on dm-3 (792 sectors) [83609.740034] btrfs-submit-1(693):
WRITE block 95077512 on dm-3 (792 sectors) [83609.740099]
btrfs-submit-1(693): WRITE block 99299048 on dm-3 (792 sectors)
[83609.740166] btrfs-submit-1(693): WRITE block 114695208 on dm-3 (792
sectors) [83609.740242] btrfs-submit-1(693): WRITE block 117871312 on
dm-3 (792 sectors) [83609.740317] btrfs-submit-1(693): WRITE block
127638816 on dm-3 (792 sectors) [83609.740396] btrfs-submit-1(693):
WRITE block 61538336 on dm-3 (784 sectors) [83609.740458]
btrfs-submit-1(693): WRITE block 62975696 on dm-3 (784 sectors)
[83609.740513] btrfs-submit-1(693): WRITE block 93785632 on dm-3 (784
sectors) [83609.740566] btrfs-submit-1(693): WRITE block 99866264 on
dm-3 (784 sectors) [83609.740622] btrfs-submit-1(693): WRITE block
142205720 on dm-3 (784 sectors) [83609.740676] btrfs-submit-1(693):
WRITE block 147347592 on dm-3 (784 sectors) [83609.740730]
btrfs-submit-1(693): WRITE block 153622520 on dm-3 (784 sectors)
[83609.740784] btrfs-submit-1(693): WRITE block 181676760 on dm-3 (784
sectors) [83609.740841] btrfs-submit-1(693): WRITE block 184377824 on
dm-3 (784 sectors) [83609.740904] btrfs-submit-1(693): WRITE block
187414376 on dm-3 (784 sectors) [83609.740959] btrfs-submit-1(693):
WRITE block 198334304 on dm-3 (784 sectors) [83609.741014]
btrfs-submit-1(693): WRITE block 63841128 on dm-3 (776 sectors)
[83609.741075] btrfs-submit-1(693): WRITE block 89510856 on dm-3 (776
sectors) [83609.741131] btrfs-submit-1(693): WRITE block 136094096 on
dm-3 (736 sectors) [83609.741137] btrfs-submit-1(693): WRITE block
136094832 on dm-3 (40 sectors) [83609.741216] btrfs-submit-1(693):
WRITE block 142929432 on dm-3 (776 sectors) [83609.741293]
btrfs-submit-1(693): WRITE block 150604280 on dm-3 (776 sectors)
[83609.741371] btrfs-submit-1(693): WRITE block 158175816 on dm-3 (776
sectors) [83609.741435] btrfs-submit-1(693): WRITE block 168649488 on
dm-3 (776 sectors) [83609.741491] btrfs-submit-1(693): WRITE block
199260856 on dm-3 (776 sectors) [83609.741544] btrfs-submit-1(693):
WRITE block 202014528 on dm-3 (776 sectors) [83609.741602]
btrfs-submit-1(693): WRITE block 203082192 on dm-3 (776 sectors)
[83609.741657] btrfs-submit-1(693): WRITE block 354515544 on dm-3 (768
sectors) [83609.741712] btrfs-submit-1(693): WRITE block 354600352 on
dm-3 (768 sectors) [83609.741768] btrfs-submit-1(693): WRITE block
354624432 on dm-3 (768 sectors) [83609.741825] btrfs-submit-1(693):
WRITE block 354661544 on dm-3 (768 sectors) [83609.741881]
btrfs-submit-1(693): WRITE block 354707656 on dm-3 (768 sectors)
[83609.741936] btrfs-submit-1(693): WRITE block 354718744 on dm-3 (768
sectors) [83609.741989] btrfs-submit-1(693): WRITE block 354753344 on
dm-3 (768 sectors) [83609.742045] btrfs-submit-1(693): WRITE block
82930600 on dm-3 (768 sectors) [83609.742107] btrfs-submit-1(693):
WRITE block 90949296 on dm-3 (768 sectors) [83609.742183]
btrfs-submit-1(693): WRITE block 93797256 on dm-3 (768 sectors)
[83609.742257] btrfs-submit-1(693): WRITE block 97875008 on dm-3 (768
sectors) [83609.742332] btrfs-submit-1(693): WRITE block 43994992 on
dm-3 (760 sectors) [83609.742401] btrfs-submit-1(693): WRITE block
52875448 on dm-3 (760 sectors) [83609.742456] btrfs-submit-1(693):
WRITE block 52891640 on dm-3 (760 sectors) [83609.742475]
btrfs-submit-1(693): WRITE block 106047616 on dm-3 (264 sectors)
[83609.742508] btrfs-submit-1(693): WRITE block 106047880 on dm-3 (496
sectors) [83609.742565] btrfs-submit-1(693): WRITE block 138267560 on
dm-3 (760 sectors) [83609.742617] btrfs-submit-1(693): WRITE block
162656536 on dm-3 (760 sectors) [83609.742669] btrfs-submit-1(693):
WRITE block 163062152 on dm-3 (760 sectors) [83609.742721]
btrfs-submit-1(693): WRITE block 168673984 on dm-3 (760 sectors)
[83609.742774] btrfs-submit-1(693): WRITE block 168746504 on dm-3 (760
sectors) [83609.742827] btrfs-submit-1(693): WRITE block 168901888 on
dm-3 (760 sectors) [83609.742885] btrfs-submit-1(693): WRITE block
191670304 on dm-3 (760 sectors) [83609.742935] btrfs-submit-1(693):
WRITE block 127014000 on dm-3 (752 sectors) [83609.742990]
btrfs-submit-1(693): WRITE block 127198480 on dm-3 (752 sectors)
[83609.743042] btrfs-submit-1(693): WRITE block 131259888 on dm-3 (752
sectors) [83609.743100] btrfs-submit-1(693): WRITE block 134412248 on
dm-3 (752 sectors) [83609.743172] btrfs-submit-1(693): WRITE block
134750600 on dm-3 (752 sectors) [83609.743246] btrfs-submit-1(693):
WRITE block 141094896 on dm-3 (752 sectors) [83609.743321]
btrfs-submit-1(693): WRITE block 141483056 on dm-3 (752 sectors)
[83609.743397] btrfs-submit-1(693): WRITE block 161497224 on dm-3 (752
sectors) [83609.743461] btrfs-submit-1(693): WRITE block 161983032 on
dm-3 (752 sectors) [83609.743515] btrfs-submit-1(693): WRITE block
162145448 on dm-3 (752 sectors) [83609.743569] btrfs-submit-1(693):
WRITE block 168906536 on dm-3 (752 sectors) [83609.743623]
btrfs-submit-1(693): WRITE block 56982192 on dm-3 (744 sectors)
[83609.743675] btrfs-submit-1(693): WRITE block 67247704 on dm-3 (744
sectors) [83609.743729] btrfs-submit-1(693): WRITE block 80350056 on
dm-3 (744 sectors) [83609.743741] btrfs-submit-1(693): WRITE block
82283432 on dm-3 (144 sectors) [83609.743782] btrfs-submit-1(693):
WRITE block 82283576 on dm-3 (600 sectors) [83609.743836]
btrfs-submit-1(693): WRITE block 97891744 on dm-3 (744 sectors)
[83609.743888] btrfs-submit-1(693): WRITE block 117480152 on dm-3 (744
sectors) [83609.743941] btrfs-submit-1(693): WRITE block 125136744 on
dm-3 (744 sectors) [83609.743994] btrfs-submit-1(693): WRITE block
162108520 on dm-3 (744 sectors) [83609.744047] btrfs-submit-1(693):
WRITE block 162241048 on dm-3 (744 sectors) [83609.744106]
btrfs-submit-1(693): WRITE block 168923160 on dm-3 (744 sectors)
[83609.744174] btrfs-submit-1(693): WRITE block 187588184 on dm-3 (744
sectors) [83609.744243] btrfs-submit-1(693): WRITE block 134794248 on
dm-3 (736 sectors) [83609.744316] btrfs-submit-1(693): WRITE block
162679192 on dm-3 (736 sectors) [83609.744386] btrfs-submit-1(693):
WRITE block 166720040 on dm-3 (736 sectors) [83609.744444]
btrfs-submit-1(693): WRITE block 168954136 on dm-3 (736 sectors)
[83609.744492] btrfs-submit-1(693): WRITE block 169003216 on dm-3 (736
sectors) [83609.744546] btrfs-submit-1(693): WRITE block 193264136 on
dm-3 (736 sectors) [83609.744597] btrfs-submit-1(693): WRITE block
202047672 on dm-3 (736 sectors) [83609.744647] btrfs-submit-1(693):
WRITE block 203622536 on dm-3 (736 sectors) [83609.744703]
btrfs-submit-1(693): WRITE block 205924536 on dm-3 (736 sectors)
[83609.744751] btrfs-submit-1(693): WRITE block 206750784 on dm-3 (736
sectors) [83609.744806] btrfs-submit-1(693): WRITE block 210224208 on
dm-3 (736 sectors) [83609.744856] btrfs-submit-1(693): WRITE block
56981456 on dm-3 (728 sectors) [83609.744910] btrfs-submit-1(693):
WRITE block 119900032 on dm-3 (728 sectors) [83609.744961]
btrfs-submit-1(693): WRITE block 142078240 on dm-3 (728 sectors)
[83609.744988] btrfs-submit-1(693): WRITE block 187218288 on dm-3 (376
sectors) [83609.745012] btrfs-submit-1(693): WRITE block 187218664 on
dm-3 (352 sectors) [83609.745070] btrfs-submit-1(693): WRITE block
210489472 on dm-3 (728 sectors) [83609.745121] btrfs-submit-1(693):
WRITE block 210518928 on dm-3 (728 sectors) [83609.745192]
btrfs-submit-1(693): WRITE block 210563888 on dm-3 (728 sectors)
[83609.745262] btrfs-submit-1(693): WRITE block 210586288 on dm-3 (728
sectors) [83609.745334] btrfs-submit-1(693): WRITE block 210871288 on
dm-3 (728 sectors) [83609.745406] btrfs-submit-1(693): WRITE block
210976008 on dm-3 (728 sectors) [83609.745462] btrfs-submit-1(693):
WRITE block 210994536 on dm-3 (728 sectors) [83609.745508]
btrfs-submit-1(693): WRITE block 82368680 on dm-3 (720 sectors)
[83609.745555] btrfs-submit-1(693): WRITE block 106040712 on dm-3 (720
sectors) [83609.745601] btrfs-submit-1(693): WRITE block 107681920 on
dm-3 (720 sectors) [83609.745652] btrfs-submit-1(693): WRITE block
112811792 on dm-3 (720 sectors) [83609.745701] btrfs-submit-1(693):
WRITE block 116864328 on dm-3 (720 sectors) [83609.745748]
btrfs-submit-1(693): WRITE block 141951128 on dm-3 (720 sectors)
[83609.745795] btrfs-submit-1(693): WRITE block 163764224 on dm-3 (720
sectors) [83609.745842] btrfs-submit-1(693): WRITE block 166627440 on
dm-3 (720 sectors) [83609.745889] btrfs-submit-1(693): WRITE block
202001072 on dm-3 (720 sectors) [83609.745937] btrfs-submit-1(693):
WRITE block 210237080 on dm-3 (720 sectors) [83609.745988]
btrfs-submit-1(693): WRITE block 211123584 on dm-3 (720 sectors)
[83609.746039] btrfs-submit-1(693): WRITE block 52179736 on dm-3 (712
sectors) [83609.746096] btrfs-submit-1(693): WRITE block 86064144 on
dm-3 (712 sectors) [83609.746156] btrfs-submit-1(693): WRITE block
89502720 on dm-3 (712 sectors) [83609.746225] btrfs-submit-1(693):
WRITE block 119241688 on dm-3 (712 sectors) [83609.746244]
btrfs-submit-1(693): WRITE block 200120976 on dm-3 (248 sectors)
[83609.746284] btrfs-submit-1(693): WRITE block 200121224 on dm-3 (464
sectors) [83609.746366] btrfs-submit-1(693): WRITE block 200499344 on
dm-3 (712 sectors) [83609.746432] btrfs-submit-1(693): WRITE block
211124376 on dm-3 (712 sectors) [83609.746486] btrfs-submit-1(693):
WRITE block 211210288 on dm-3 (712 sectors) [83609.746533]
btrfs-submit-1(693): WRITE block 211529816 on dm-3 (712 sectors)
[83609.746581] btrfs-submit-1(693): WRITE block 211547728 on dm-3 (712
sectors) [83609.746627] btrfs-submit-1(693): WRITE block 211661520 on
dm-3 (712 sectors) [83609.746672] btrfs-submit-1(693): WRITE block
211761592 on dm-3 (712 sectors) [83609.746720] btrfs-submit-1(693):
WRITE block 327239848 on dm-3 (704 sectors) [83609.746771]
btrfs-submit-1(693): WRITE block 346395928 on dm-3 (704 sectors)
[83609.746816] btrfs-submit-1(693): WRITE block 346398456 on dm-3 (704
sectors) [83609.746862] btrfs-submit-1(693): WRITE block 346465176 on
dm-3 (704 sectors) [83609.746908] btrfs-submit-1(693): WRITE block
52263224 on dm-3 (704 sectors) [83609.746955] btrfs-submit-1(693):
WRITE block 58247888 on dm-3 (704 sectors) [83609.747000]
btrfs-submit-1(693): WRITE block 67472216 on dm-3 (704 sectors)
[83609.747045] btrfs-submit-1(693): WRITE block 99375208 on dm-3 (704
sectors) [83609.747122] btrfs-submit-1(693): WRITE block 117039712 on
dm-3 (704 sectors) [83609.747140] btrfs-submit-1(693): WRITE block
147169096 on dm-3 (704 sectors) [83609.747206] btrfs-submit-1(693):
WRITE block 189141360 on dm-3 (704 sectors) [83609.747273]
btrfs-submit-1(693): WRITE block 68589128 on dm-3 (696 sectors)
[83609.747342] btrfs-submit-1(693): WRITE block 81355048 on dm-3 (696
sectors) [83609.747413] btrfs-submit-1(693): WRITE block 93920584 on
dm-3 (696 sectors) [83609.747462] btrfs-submit-1(693): WRITE block
99379968 on dm-3 (696 sectors) [83609.747495] btrfs-submit-1(693):
WRITE block 101110680 on dm-3 (488 sectors) [83609.747511]
btrfs-submit-1(693): WRITE block 101111168 on dm-3 (208 sectors)
[83609.747565] btrfs-submit-1(693): WRITE block 114714320 on dm-3 (696
sectors) [83609.747610] btrfs-submit-1(693): WRITE block 119939168 on
dm-3 (696 sectors) [83609.747655] btrfs-submit-1(693): WRITE block
199874248 on dm-3 (696 sectors) [83609.747702] btrfs-submit-1(693):
WRITE block 203063624 on dm-3 (696 sectors) [83609.747748]
btrfs-submit-1(693): WRITE block 203536744 on dm-3 (696 sectors)
[83609.747794] btrfs-submit-1(693): WRITE block 207399744 on dm-3 (696
sectors) [83609.747839] btrfs-submit-1(693): WRITE block 207422496 on
dm-3 (696 sectors) [83609.747884] btrfs-submit-1(693): WRITE block
81546664 on dm-3 (688 sectors) [83609.747930] btrfs-submit-1(693):
WRITE block 122246840 on dm-3 (688 sectors) [83609.747975]
btrfs-submit-1(693): WRITE block 126918344 on dm-3 (688 sectors)
[83609.748020] btrfs-submit-1(693): WRITE block 182993632 on dm-3 (688
sectors) [83609.748071] btrfs-submit-1(693): WRITE block 187306400 on
dm-3 (688 sectors) [83609.748116] btrfs-submit-1(693): WRITE block
200124088 on dm-3 (688 sectors) [83609.748160] btrfs-submit-1(693):
WRITE block 207912840 on dm-3 (688 sectors) [83609.748205]
btrfs-submit-1(693): WRITE block 209312112 on dm-3 (688 sectors)
[83609.748263] btrfs-submit-1(693): WRITE block 210164352 on dm-3 (688
sectors) [83609.748330] btrfs-submit-1(693): WRITE block 211138272 on
dm-3 (688 sectors) [83609.748397] btrfs-submit-1(693): WRITE block
211775816 on dm-3 (688 sectors) [83609.748467] btrfs-submit-1(693):
WRITE block 211780712 on dm-3 (688 sectors) [83609.748511]
btrfs-submit-1(693): WRITE block 52589480 on dm-3 (680 sectors)
[83609.748556] btrfs-submit-1(693): WRITE block 99376080 on dm-3 (680
sectors) [83609.748599] btrfs-submit-1(693): WRITE block 106033696 on
dm-3 (680 sectors) [83609.748644] btrfs-submit-1(693): WRITE block
199856936 on dm-3 (680 sectors) [83609.748672] btrfs-submit-1(693):
WRITE block 210363096 on dm-3 (408 sectors) [83609.748691]
btrfs-submit-1(693): WRITE block 210363504 on dm-3 (272 sectors)
[83609.748735] btrfs-submit-1(693): WRITE block 211817480 on dm-3 (680
sectors) [83609.748779] btrfs-submit-1(693): WRITE block 211838720 on
dm-3 (680 sectors) [83609.748822] btrfs-submit-1(693): WRITE block
212074952 on dm-3 (680 sectors) [83609.748869] btrfs-submit-1(693):
WRITE block 212136280 on dm-3 (680 sectors) [83609.748912]
btrfs-submit-1(693): WRITE block 212324784 on dm-3 (680 sectors)
[83609.748956] btrfs-submit-1(693): WRITE block 212377656 on dm-3 (680
sectors) [83609.749001] btrfs-submit-1(693): WRITE block 212408744 on
dm-3 (680 sectors) [83609.749048] btrfs-submit-1(693): WRITE block
326454160 on dm-3 (672 sectors) [83609.749099] btrfs-submit-1(693):
WRITE block 326454976 on dm-3 (672 sectors) [83609.749147]
btrfs-submit-1(693): WRITE block 326593120 on dm-3 (672 sectors)
[83609.749216] btrfs-submit-1(693): WRITE block 326623992 on dm-3 (672
sectors) [83609.749280] btrfs-submit-1(693): WRITE block 326642864 on
dm-3 (672 sectors) [83609.749346] btrfs-submit-1(693): WRITE block
326645168 on dm-3 (672 sectors) [83609.749411] btrfs-submit-1(693):
WRITE block 326692280 on dm-3 (672 sectors) [83609.749465]
btrfs-submit-1(693): WRITE block 360419288 on dm-3 (672 sectors)
[83609.749510] btrfs-submit-1(693): WRITE block 40907824 on dm-3 (672
sectors) [83609.749556] btrfs-submit-1(693): WRITE block 56741192 on
dm-3 (672 sectors) [83609.749600] btrfs-submit-1(693): WRITE block
60884704 on dm-3 (672 sectors) [83609.749644] btrfs-submit-1(693):
WRITE block 93491912 on dm-3 (672 sectors) [83609.749687]
btrfs-submit-1(693): WRITE block 59809176 on dm-3 (664 sectors)
[83609.749731] btrfs-submit-1(693): WRITE block 82931464 on dm-3 (664
sectors) [83609.749773] btrfs-submit-1(693): WRITE block 93694352 on
dm-3 (664 sectors) [83609.749817] btrfs-submit-1(693): WRITE block
93700944 on dm-3 (664 sectors) [83609.749862] btrfs-submit-1(693):
WRITE block 99852960 on dm-3 (664 sectors) [83609.749866]
btrfs-submit-1(693): WRITE block 119614528 on dm-3 (48 sectors)
[83609.749906] btrfs-submit-1(693): WRITE block 119614576 on dm-3 (616
sectors) [83609.749950] btrfs-submit-1(693): WRITE block 134687664 on
dm-3 (664 sectors) [83609.749993] btrfs-submit-1(693): WRITE block
166375936 on dm-3 (664 sectors) [83609.750037] btrfs-submit-1(693):
WRITE block 174029464 on dm-3 (664 sectors) [83609.750089]
btrfs-submit-1(693): WRITE block 184113264 on dm-3 (664 sectors)
[83609.750130] btrfs-submit-1(693): WRITE block 187042304 on dm-3 (664
sectors) [83609.750173] btrfs-submit-1(693): WRITE block 193459752 on
dm-3 (664 sectors) [83609.750233] btrfs-submit-1(693): WRITE block
203174312 on dm-3 (664 sectors) [83609.750299] btrfs-submit-1(693):
WRITE block 55900320 on dm-3 (656 sectors) [83609.750363]
btrfs-submit-1(693): WRITE block 99232432 on dm-3 (656 sectors)
[83609.750427] btrfs-submit-1(693): WRITE block 143493416 on dm-3 (656
sectors) [83609.750493] btrfs-submit-1(693): WRITE block 182038440 on
dm-3 (656 sectors) [83609.750536] btrfs-submit-1(693): WRITE block
200201696 on dm-3 (656 sectors) [83609.750580] btrfs-submit-1(693):
WRITE block 204123696 on dm-3 (656 sectors) [83609.750622]
btrfs-submit-1(693): WRITE block 204208576 on dm-3 (656 sectors)
[83609.750666] btrfs-submit-1(693): WRITE block 205274256 on dm-3 (656
sectors) [83609.750708] btrfs-submit-1(693): WRITE block 205763416 on
dm-3 (656 sectors) [83609.750750] btrfs-submit-1(693): WRITE block
206088472 on dm-3 (656 sectors) [83609.750793] btrfs-submit-1(693):
WRITE block 207701688 on dm-3 (656 sectors) [83609.750836]
btrfs-submit-1(693): WRITE block 207709976 on dm-3 (656 sectors)
[83609.750881] btrfs-submit-1(693): WRITE block 46952680 on dm-3 (648
sectors) [83609.750925] btrfs-submit-1(693): WRITE block 47409528 on
dm-3 (648 sectors) [83609.750967] btrfs-submit-1(693): WRITE block
81827736 on dm-3 (648 sectors) [83609.751009] btrfs-submit-1(693):
WRITE block 93491016 on dm-3 (648 sectors) [83609.751052]
btrfs-submit-1(693): WRITE block 101058096 on dm-3 (648 sectors)
[83609.751063] btrfs-submit-1(693): WRITE block 108111224 on dm-3 (88
sectors) [83609.751098] btrfs-submit-1(693): WRITE block 108111312 on
dm-3 (560 sectors) [83609.751140] btrfs-submit-1(693): WRITE block
114696480 on dm-3 (648 sectors) [83609.751200] btrfs-submit-1(693):
WRITE block 134745800 on dm-3 (648 sectors) [83609.751261]
btrfs-submit-1(693): WRITE block 164791448 on dm-3 (648 sectors)
[83609.751324] btrfs-submit-1(693): WRITE block 182970208 on dm-3 (648
sectors) [83609.751387] btrfs-submit-1(693): WRITE block 198622456 on
dm-3 (648 sectors) [83609.751447] btrfs-submit-1(693): WRITE block
198624712 on dm-3 (648 sectors) [83609.751489] btrfs-submit-1(693):
WRITE block 199115848 on dm-3 (648 sectors) [83609.751532]
btrfs-submit-1(693): WRITE block 347721336 on dm-3 (640 sectors)
[83609.751573] btrfs-submit-1(693): WRITE block 347779928 on dm-3 (640
sectors) [83609.751615] btrfs-submit-1(693): WRITE block 347784160 on
dm-3 (640 sectors) [83609.751659] btrfs-submit-1(693): WRITE block
56932600 on dm-3 (640 sectors) [83609.751704] btrfs-submit-1(693):
WRITE block 93849816 on dm-3 (640 sectors) [83609.751749]
btrfs-submit-1(693): WRITE block 108284088 on dm-3 (640 sectors)
[83609.751791] btrfs-submit-1(693): WRITE block 115388488 on dm-3 (640
sectors) [83609.751834] btrfs-submit-1(693): WRITE block 137234128 on
dm-3 (640 sectors) [83609.751876] btrfs-submit-1(693): WRITE block
176360872 on dm-3 (640 sectors) [83609.751918] btrfs-submit-1(693):
WRITE block 183916024 on dm-3 (640 sectors) [83609.751960]
btrfs-submit-1(693): WRITE block 184413640 on dm-3 (640 sectors)
[83609.752002] btrfs-submit-1(693): WRITE block 198619800 on dm-3 (640
sectors) [83609.752044] btrfs-submit-1(693): WRITE block 199175328 on
dm-3 (640 sectors) [83609.752098] btrfs-submit-1(693): WRITE block
56970464 on dm-3 (632 sectors) [83609.752141] btrfs-submit-1(693):
WRITE block 82733128 on dm-3 (632 sectors) [83609.752184]
btrfs-submit-1(693): WRITE block 83279808 on dm-3 (632 sectors)
[83609.752225] btrfs-submit-1(693): WRITE block 99499720 on dm-3 (632
sectors) [83609.752267] btrfs-submit-1(693): WRITE block 105554664 on
dm-3 (520 sectors) [83609.752276] btrfs-submit-1(693): WRITE block
105555184 on dm-3 (112 sectors) [83609.752348] btrfs-submit-1(693):
WRITE block 112823480 on dm-3 (632 sectors) [83609.752410]
btrfs-submit-1(693): WRITE block 138272320 on dm-3 (632 sectors)
[83609.752469] btrfs-submit-1(693): WRITE block 170295704 on dm-3 (632
sectors) [83609.752520] btrfs-submit-1(693): WRITE block 191925160 on
dm-3 (632 sectors) [83609.752561] btrfs-submit-1(693): WRITE block
196663528 on dm-3 (632 sectors) [83609.752602] btrfs-submit-1(693):
WRITE block 198062248 on dm-3 (632 sectors) [83609.752644]
btrfs-submit-1(693): WRITE block 198445520 on dm-3 (632 sectors)
[83609.752684] btrfs-submit-1(693): WRITE block 199262280 on dm-3 (632
sectors) [83609.752724] btrfs-submit-1(693): WRITE block 38548664 on
dm-3 (624 sectors) [83609.752765] btrfs-submit-1(693): WRITE block
63953960 on dm-3 (624 sectors) [83609.752806] btrfs-submit-1(693):
WRITE block 97879664 on dm-3 (624 sectors) [83609.752847]
btrfs-submit-1(693): WRITE block 97951544 on dm-3 (624 sectors)
[83609.752889] btrfs-submit-1(693): WRITE block 113422568 on dm-3 (624
sectors) [83609.752930] btrfs-submit-1(693): WRITE block 114892176 on
dm-3 (624 sectors) [83609.752971] btrfs-submit-1(693): WRITE block
117681312 on dm-3 (624 sectors) [83609.753011] btrfs-submit-1(693):
WRITE block 150346816 on dm-3 (624 sectors) [83609.753053]
btrfs-submit-1(693): WRITE block 169286712 on dm-3 (624 sectors)
[83609.753099] btrfs-submit-1(693): WRITE block 173326648 on dm-3 (624
sectors) [83609.753140] btrfs-submit-1(693): WRITE block 187315616 on
dm-3 (624 sectors) [83609.753202] btrfs-submit-1(693): WRITE block
187839976 on dm-3 (624 sectors) [83609.753264] btrfs-submit-1(693):
WRITE block 197907024 on dm-3 (624 sectors) [83609.753324]
btrfs-submit-1(693): WRITE block 97970656 on dm-3 (616 sectors)
[83609.753385] btrfs-submit-1(693): WRITE block 112318992 on dm-3 (616
sectors) [83609.753439] btrfs-submit-1(693): WRITE block 122064504 on
dm-3 (616 sectors) [83609.753479] btrfs-submit-1(693): WRITE block
127463784 on dm-3 (616 sectors) [83609.753519] btrfs-submit-1(693):
WRITE block 135601040 on dm-3 (616 sectors) [83609.753528]
btrfs-submit-1(693): WRITE block 139689928 on dm-3 (104 sectors)
[83609.753561] btrfs-submit-1(693): WRITE block 139690032 on dm-3 (512
sectors) [83609.753602] btrfs-submit-1(693): WRITE block 145019520 on
dm-3 (616 sectors) [83609.753646] btrfs-submit-1(693): WRITE block
180960056 on dm-3 (616 sectors) [83609.753688] btrfs-submit-1(693):
WRITE block 194196976 on dm-3 (616 sectors) [83609.753731]
btrfs-submit-1(693): WRITE block 194552000 on dm-3 (616 sectors)
[83609.753772] btrfs-submit-1(693): WRITE block 194871360 on dm-3 (616
sectors) [83609.753813] btrfs-submit-1(693): WRITE block 197999280 on
dm-3 (616 sectors) [83609.753854] btrfs-submit-1(693): WRITE block
198161424 on dm-3 (616 sectors) [83609.753894] btrfs-submit-1(693):
WRITE block 48696240 on dm-3 (608 sectors) [83609.753934]
btrfs-submit-1(693): WRITE block 51494248 on dm-3 (608 sectors)
[83609.753974] btrfs-submit-1(693): WRITE block 82934264 on dm-3 (608
sectors) [83609.754014] btrfs-submit-1(693): WRITE block 83568168 on
dm-3 (608 sectors) [83609.754085] btrfs-submit-1(693): WRITE block
99237312 on dm-3 (608 sectors) [83609.754104] btrfs-submit-1(693):
WRITE block 116943112 on dm-3 (608 sectors) [83609.754143]
btrfs-submit-1(693): WRITE block 139938040 on dm-3 (608 sectors)
[83609.754184] btrfs-submit-1(693): WRITE block 164233480 on dm-3 (608
sectors) [83609.754234] btrfs-submit-1(693): WRITE block 173385696 on
dm-3 (608 sectors) [83609.754294] btrfs-submit-1(693): WRITE block
183169832 on dm-3 (608 sectors) [83609.754355] btrfs-submit-1(693):
WRITE block 193049616 on dm-3 (608 sectors) [83609.754413]
btrfs-submit-1(693): WRITE block 194338760 on dm-3 (608 sectors)
[83609.754472] btrfs-submit-1(693): WRITE block 195151072 on dm-3 (608
sectors) [83609.754530] btrfs-submit-1(693): WRITE block 56893768 on
dm-3 (600 sectors) [83609.754570] btrfs-submit-1(693): WRITE block
121463200 on dm-3 (600 sectors) [83609.754612] btrfs-submit-1(693):
WRITE block 126649056 on dm-3 (600 sectors) [83609.754653]
btrfs-submit-1(693): WRITE block 139799192 on dm-3 (600 sectors)
[83609.754695] btrfs-submit-1(693): WRITE block 188909192 on dm-3 (600
sectors) [83609.754737] btrfs-submit-1(693): WRITE block 189552104 on
dm-3 (600 sectors) [83609.754748] btrfs-submit-1(693): WRITE block
189660712 on dm-3 (136 sectors) [83609.754779] btrfs-submit-1(693):
WRITE block 189660848 on dm-3 (464 sectors) [83609.754820]
btrfs-submit-1(693): WRITE block 192970688 on dm-3 (600 sectors)
[83609.754861] btrfs-submit-1(693): WRITE block 194191288 on dm-3 (600
sectors) [83609.754903] btrfs-submit-1(693): WRITE block 195439456 on
dm-3 (600 sectors) [83609.754943] btrfs-submit-1(693): WRITE block
196297984 on dm-3 (600 sectors) [83609.754984] btrfs-submit-1(693):
WRITE block 197897224 on dm-3 (600 sectors) [83609.755024]
btrfs-submit-1(693): WRITE block 198243168 on dm-3 (600 sectors)
[83609.755098] btrfs-submit-1(693): WRITE block 198439464 on dm-3 (600
sectors) [83609.755121] btrfs-submit-1(693): WRITE block 38542080 on
dm-3 (592 sectors) [83609.755159] btrfs-submit-1(693): WRITE block
47655440 on dm-3 (592 sectors) [83609.755199] btrfs-submit-1(693):
WRITE block 52007432 on dm-3 (592 sectors) [83609.755239]
btrfs-submit-1(693): WRITE block 104573568 on dm-3 (592 sectors)
[83609.755296] btrfs-submit-1(693): WRITE block 113661216 on dm-3 (592
sectors) [83609.755356] btrfs-submit-1(693): WRITE block 126177400 on
dm-3 (592 sectors) [83609.755416] btrfs-submit-1(693): WRITE block
150354288 on dm-3 (592 sectors) [83609.755473] btrfs-submit-1(693):
WRITE block 160023648 on dm-3 (592 sectors) [83609.755516]
btrfs-submit-1(693): WRITE block 173544704 on dm-3 (592 sectors)
[83609.755558] btrfs-submit-1(693): WRITE block 187081040 on dm-3 (592
sectors) [83609.755601] btrfs-submit-1(693): WRITE block 188872704 on
dm-3 (592 sectors) [83609.755645] btrfs-submit-1(693): WRITE block
188967728 on dm-3 (592 sectors) [83609.755688] btrfs-submit-1(693):
WRITE block 189098896 on dm-3 (592 sectors) [83609.755733]
btrfs-submit-1(693): WRITE block 189203888 on dm-3 (592 sectors)
[83609.755773] btrfs-submit-1(693): WRITE block 47527856 on dm-3 (584
sectors) [83609.755817] btrfs-submit-1(693): WRITE block 56904912 on
dm-3 (584 sectors) [83609.755862] btrfs-submit-1(693): WRITE block
81553320 on dm-3 (584 sectors) [83609.755900] btrfs-submit-1(693):
WRITE block 82172872 on dm-3 (584 sectors) [83609.755944]
btrfs-submit-1(693): WRITE block 82694392 on dm-3 (584 sectors)
[83609.755986] btrfs-submit-1(693): WRITE block 93696112 on dm-3 (584
sectors) [83609.755989] btrfs-submit-1(693): WRITE block 97880544 on
dm-3 (8 sectors) [83609.756032] btrfs-submit-1(693): WRITE block
97880552 on dm-3 (576 sectors) [83609.756079] btrfs-submit-1(693):
WRITE block 99236616 on dm-3 (584 sectors) [83609.756128]
btrfs-submit-1(693): WRITE block 108097040 on dm-3 (584 sectors)
[83609.756186] btrfs-submit-1(693): WRITE block 113604176 on dm-3 (584
sectors) [83609.756244] btrfs-submit-1(693): WRITE block 114203536 on
dm-3 (584 sectors) [83609.756303] btrfs-submit-1(693): WRITE block
121994752 on dm-3 (584 sectors) [83609.756363] btrfs-submit-1(693):
WRITE block 122058744 on dm-3 (584 sectors) [83609.756424]
btrfs-submit-1(693): WRITE block 125752880 on dm-3 (584 sectors)
[83609.756540] btrfs-submit-1(693): WRITE block 321501144 on dm-3
(1024 sectors) [83609.756551] btrfs-submit-1(693): WRITE block
321502168 on dm-3 (136 sectors) [83609.756589] btrfs-submit-1(693):
WRITE block 56201504 on dm-3 (576 sectors) [83609.756628]
btrfs-submit-1(693): WRITE block 57098472 on dm-3 (576 sectors)
[83609.756666] btrfs-submit-1(693): WRITE block 57587784 on dm-3 (576
sectors) [83609.756705] btrfs-submit-1(693): WRITE block 59981320 on
dm-3 (576 sectors) [83609.756744] btrfs-submit-1(693): WRITE block
61710272 on dm-3 (576 sectors) [83609.756810] btrfs-submit-1(693):
WRITE block 319170752 on dm-3 (1024 sectors) [83609.756820]
btrfs-submit-1(693): WRITE block 319171776 on dm-3 (128 sectors)
[83609.756887] btrfs-submit-1(693): WRITE block 348001976 on dm-3
(1024 sectors) [83609.756897] btrfs-submit-1(693): WRITE block
348003000 on dm-3 (128 sectors) [83609.756963] btrfs-submit-1(693):
WRITE block 352420904 on dm-3 (1024 sectors) [83609.756973]
btrfs-submit-1(693): WRITE block 352421928 on dm-3 (128 sectors)
[83609.757011] btrfs-submit-1(693): WRITE block 63187680 on dm-3 (576
sectors) [83609.757083] btrfs-submit-1(693): WRITE block 327402728 on
dm-3 (1024 sectors) [83609.757095] btrfs-submit-1(693): WRITE block
327403752 on dm-3 (120 sectors) [83609.757133] btrfs-submit-1(693):
WRITE block 51127736 on dm-3 (568 sectors) [83609.757171]
btrfs-submit-1(693): WRITE block 57942064 on dm-3 (568 sectors)
[83609.757208] btrfs-submit-1(693): WRITE block 61457680 on dm-3 (568
sectors) [83609.757246] btrfs-submit-1(693): WRITE block 65072872 on
dm-3 (568 sectors) [83609.757268] btrfs-submit-1(693): WRITE block
66095976 on dm-3 (312 sectors) [83609.757286] btrfs-submit-1(693):
WRITE block 66096288 on dm-3 (256 sectors) [83609.757351]
btrfs-submit-1(693): WRITE block 66321080 on dm-3 (568 sectors)
[83609.757411] btrfs-submit-1(693): WRITE block 66595040 on dm-3 (568
sectors) [83609.757468] btrfs-submit-1(693): WRITE block 66757280 on
dm-3 (568 sectors) [83609.757515] btrfs-submit-1(693): WRITE block
67040576 on dm-3 (568 sectors) [83609.757557] btrfs-submit-1(693):
WRITE block 68515712 on dm-3 (568 sectors) [83609.757595]
btrfs-submit-1(693): WRITE block 68965560 on dm-3 (568 sectors)
[83609.757637] btrfs-submit-1(693): WRITE block 69082048 on dm-3 (568
sectors) [83609.757741] btrfs-submit-1(693): WRITE block 331244144 on
dm-3 (1024 sectors) [83609.757750] btrfs-submit-1(693): WRITE block
331245168 on dm-3 (104 sectors) [83609.757826] btrfs-submit-1(693):
WRITE block 331812136 on dm-3 (1024 sectors) [83609.757835]
btrfs-submit-1(693): WRITE block 331813160 on dm-3 (104 sectors)
[83609.757907] btrfs-submit-1(693): WRITE block 354210136 on dm-3
(1024 sectors) [83609.757916] btrfs-submit-1(693): WRITE block
354211160 on dm-3 (104 sectors) [83609.757954] btrfs-submit-1(693):
WRITE block 38730456 on dm-3 (560 sectors) [83609.757991]
btrfs-submit-1(693): WRITE block 46825456 on dm-3 (560 sectors)
[83609.758082] btrfs-submit-1(693): WRITE block 327483976 on dm-3
(1024 sectors) [83609.758093] btrfs-submit-1(693): WRITE block
327485000 on dm-3 (96 sectors) [83609.758137] btrfs-submit-1(693):
WRITE block 331388040 on dm-3 (1024 sectors) [83609.758145]
btrfs-submit-1(693): WRITE block 331389064 on dm-3 (96 sectors)
[83609.758248] btrfs-submit-1(693): WRITE block 358000448 on dm-3
(1024 sectors) [83609.758256] btrfs-submit-1(693): WRITE block
358001472 on dm-3 (96 sectors) [83609.758359] btrfs-submit-1(693):
WRITE block 361035624 on dm-3 (1024 sectors) [83609.758367]
btrfs-submit-1(693): WRITE block 361036648 on dm-3 (96 sectors)
[83609.758470] btrfs-submit-1(693): WRITE block 327463888 on dm-3
(1024 sectors) [83609.758477] btrfs-submit-1(693): WRITE block
327464912 on dm-3 (88 sectors) [83609.758552] btrfs-submit-1(693):
WRITE block 329205192 on dm-3 (1024 sectors) [83609.758559]
btrfs-submit-1(693): WRITE block 329206216 on dm-3 (88 sectors)
[83609.758626] btrfs-submit-1(693): WRITE block 332978328 on dm-3
(1024 sectors) [83609.758634] btrfs-submit-1(693): WRITE block
332979352 on dm-3 (88 sectors) [83609.758700] btrfs-submit-1(693):
WRITE block 321533128 on dm-3 (1024 sectors) [83609.758707]
btrfs-submit-1(693): WRITE block 321534152 on dm-3 (80 sectors)
[83609.758772] btrfs-submit-1(693): WRITE block 327680160 on dm-3
(1024 sectors) [83609.758780] btrfs-submit-1(693): WRITE block
327681184 on dm-3 (80 sectors) [83609.758852] btrfs-submit-1(693):
WRITE block 333124248 on dm-3 (1024 sectors) [83609.758859]
btrfs-submit-1(693): WRITE block 333125272 on dm-3 (80 sectors)
[83609.758937] btrfs-submit-1(693): WRITE block 335835792 on dm-3
(1024 sectors) [83609.758943] btrfs-submit-1(693): WRITE block
335836816 on dm-3 (80 sectors) [83609.759020] btrfs-submit-1(693):
WRITE block 323434056 on dm-3 (1024 sectors) [83609.759026]
btrfs-submit-1(693): WRITE block 323435080 on dm-3 (72 sectors)
[83609.759125] btrfs-submit-1(693): WRITE block 324562304 on dm-3
(1024 sectors) [83609.759130] btrfs-submit-1(693): WRITE block
324563328 on dm-3 (72 sectors) [83609.759211] btrfs-submit-1(693):
WRITE block 331331096 on dm-3 (1024 sectors) [83609.759218]
btrfs-submit-1(693): WRITE block 331332120 on dm-3 (72 sectors)
[83609.759319] btrfs-submit-1(693): WRITE block 337739664 on dm-3
(1024 sectors) [83609.759324] btrfs-submit-1(693): WRITE block
337740688 on dm-3 (72 sectors) [83609.759425] btrfs-submit-1(693):
WRITE block 323164096 on dm-3 (1024 sectors) [83609.759431]
btrfs-submit-1(693): WRITE block 323165120 on dm-3 (64 sectors)
[83609.759519] btrfs-submit-1(693): WRITE block 326050480 on dm-3
(1024 sectors) [83609.759525] btrfs-submit-1(693): WRITE block
326051504 on dm-3 (64 sectors) [83609.759598] btrfs-submit-1(693):
WRITE block 328555768 on dm-3 (1024 sectors) [83609.759604]
btrfs-submit-1(693): WRITE block 328556792 on dm-3 (64 sectors)
[83609.759675] btrfs-submit-1(693): WRITE block 329420360 on dm-3
(1024 sectors) [83609.759681] btrfs-submit-1(693): WRITE block
329421384 on dm-3 (64 sectors) [83609.759752] btrfs-submit-1(693):
WRITE block 295405824 on dm-3 (1024 sectors) [83609.759757]
btrfs-submit-1(693): WRITE block 295406848 on dm-3 (56 sectors)
[83609.759828] btrfs-submit-1(693): WRITE block 303370448 on dm-3
(1024 sectors) [83609.759833] btrfs-submit-1(693): WRITE block
303371472 on dm-3 (56 sectors) [83609.759897] btrfs-submit-1(693):
WRITE block 317914840 on dm-3 (1024 sectors) [83609.759901]
btrfs-submit-1(693): WRITE block 317915864 on dm-3 (40 sectors)
[83609.759905] btrfs-submit-1(693): WRITE block 317915904 on dm-3 (16
sectors) [83609.759971] btrfs-submit-1(693): WRITE block 295684528 on
dm-3 (1024 sectors) [83609.759974] btrfs-submit-1(693): WRITE block
295685552 on dm-3 (48 sectors) [83609.760038] btrfs-submit-1(693):
WRITE block 295631976 on dm-3 (1024 sectors) [83609.760043]
btrfs-submit-1(693): WRITE block 295633000 on dm-3 (48 sectors)
[83609.760111] btrfs-submit-1(693): WRITE block 302815216 on dm-3
(1024 sectors) [83609.760115] btrfs-submit-1(693): WRITE block
302816240 on dm-3 (48 sectors) [83609.760189] btrfs-submit-1(693):
WRITE block 318981032 on dm-3 (1024 sectors) [83609.760194]
btrfs-submit-1(693): WRITE block 318982056 on dm-3 (48 sectors)
[83609.760291] btrfs-submit-1(693): WRITE block 296556560 on dm-3
(1024 sectors) [83609.760295] btrfs-submit-1(693): WRITE block
296557584 on dm-3 (40 sectors) [83609.760396] btrfs-submit-1(693):
WRITE block 304556264 on dm-3 (1024 sectors) [83609.760400]
btrfs-submit-1(693): WRITE block 304557288 on dm-3 (40 sectors)
[83609.760497] btrfs-submit-1(693): WRITE block 305376728 on dm-3
(1024 sectors) [83609.760500] btrfs-submit-1(693): WRITE block
305377752 on dm-3 (40 sectors) [83609.760600] btrfs-submit-1(693):
WRITE block 312578072 on dm-3 (1024 sectors) [83609.760605]
btrfs-submit-1(693): WRITE block 312579096 on dm-3 (40 sectors)
[83609.760676] btrfs-submit-1(693): WRITE block 295040928 on dm-3
(1024 sectors) [83609.760679] btrfs-submit-1(693): WRITE block
295041952 on dm-3 (32 sectors) [83609.760747] btrfs-submit-1(693):
WRITE block 301459072 on dm-3 (1024 sectors) [83609.760751]
btrfs-submit-1(693): WRITE block 301460096 on dm-3 (32 sectors)
[83609.760821] btrfs-submit-1(693): WRITE block 309168168 on dm-3
(1024 sectors) [83609.760824] btrfs-submit-1(693): WRITE block
309169192 on dm-3 (32 sectors) [83609.760895] btrfs-submit-1(693):
WRITE block 309723632 on dm-3 (1024 sectors) [83609.760900]
btrfs-submit-1(693): WRITE block 309724656 on dm-3 (32 sectors)
[83609.760969] btrfs-submit-1(693): WRITE block 286079400 on dm-3
(1024 sectors) [83609.760973] btrfs-submit-1(693): WRITE block
286080424 on dm-3 (24 sectors) [83609.761039] btrfs-submit-1(693):
WRITE block 305653136 on dm-3 (1024 sectors) [83609.761044]
btrfs-submit-1(693): WRITE block 305654160 on dm-3 (24 sectors)
[83609.761116] btrfs-submit-1(693): WRITE block 305724600 on dm-3
(1024 sectors) [83609.761120] btrfs-submit-1(693): WRITE block
305725624 on dm-3 (24 sectors) [83609.761155] btrfs-submit-1(693):
WRITE block 312987296 on dm-3 (536 sectors) [83609.761191]
btrfs-submit-1(693): WRITE block 312987832 on dm-3 (512 sectors)
[83609.761314] btrfs-submit-1(693): WRITE block 256741048 on dm-3
(1024 sectors) [83609.761317] btrfs-submit-1(693): WRITE block
256742072 on dm-3 (16 sectors) [83609.761411] btrfs-submit-1(693):
WRITE block 257187280 on dm-3 (1024 sectors) [83609.761416]
btrfs-submit-1(693): WRITE block 257188304 on dm-3 (16 sectors)
[83609.761490] btrfs-submit-1(693): WRITE block 283875304 on dm-3
(1024 sectors) [83609.761493] btrfs-submit-1(693): WRITE block
283876328 on dm-3 (16 sectors) [83609.761556] btrfs-submit-1(693):
WRITE block 284676320 on dm-3 (1024 sectors) [83609.761560]
btrfs-submit-1(693): WRITE block 284677344 on dm-3 (16 sectors)
[83609.761620] btrfs-submit-1(693): WRITE block 247016808 on dm-3
(1024 sectors) [83609.761624] btrfs-submit-1(693): WRITE block
247017832 on dm-3 (8 sectors) [83609.761685] btrfs-submit-1(693):
WRITE block 247355024 on dm-3 (1024 sectors) [83609.761690]
btrfs-submit-1(693): WRITE block 247356048 on dm-3 (8 sectors)
[83609.761751] btrfs-submit-1(693): WRITE block 247360208 on dm-3
(1024 sectors) [83609.761755] btrfs-submit-1(693): WRITE block
247361232 on dm-3 (8 sectors) [83609.761817] btrfs-submit-1(693):
WRITE block 248788488 on dm-3 (1024 sectors) [83609.761821]
btrfs-submit-1(693): WRITE block 248789512 on dm-3 (8 sectors)
[83609.761883] btrfs-submit-1(693): WRITE block 247349848 on dm-3
(1024 sectors) [83609.761949] btrfs-submit-1(693): WRITE block
247351144 on dm-3 (1024 sectors) [83609.762015] btrfs-submit-1(693):
WRITE block 247352440 on dm-3 (1024 sectors) [83609.762093]
btrfs-submit-1(693): WRITE block 247356328 on dm-3 (1024 sectors)
[83609.762166] btrfs-submit-1(693): WRITE block 247357624 on dm-3
(1016 sectors) [83609.762267] btrfs-submit-1(693): WRITE block
248338872 on dm-3 (1016 sectors) [83609.762367] btrfs-submit-1(693):
WRITE block 248783312 on dm-3 (1016 sectors) [83609.762403]
btrfs-submit-1(693): WRITE block 248784608 on dm-3 (520 sectors)
[83609.762437] btrfs-submit-1(693): WRITE block 248785128 on dm-3 (496
sectors) [83609.762543] btrfs-submit-1(693): WRITE block 246165000 on
dm-3 (1008 sectors) [83609.762617] btrfs-submit-1(693): WRITE block
246738856 on dm-3 (1008 sectors) [83609.762685] btrfs-submit-1(693):
WRITE block 247514928 on dm-3 (1008 sectors) [83609.762750]
btrfs-submit-1(693): WRITE block 248489152 on dm-3 (1008 sectors)
[83609.762814] btrfs-submit-1(693): WRITE block 247344848 on dm-3
(1000 sectors) [83609.762876] btrfs-submit-1(693): WRITE block
248785904 on dm-3 (1000 sectors) [83609.762943] btrfs-submit-1(693):
WRITE block 248787200 on dm-3 (1000 sectors) [83609.763007]
btrfs-submit-1(693): WRITE block 248789784 on dm-3 (1000 sectors)
[83609.763077] btrfs-submit-1(693): WRITE block 248791088 on dm-3 (992
sectors) [83609.763137] btrfs-submit-1(693): WRITE block 248792384 on
dm-3 (992 sectors) [83609.763237] btrfs-submit-1(693): WRITE block
248793672 on dm-3 (992 sectors) [83609.763333] btrfs-submit-1(693):
WRITE block 248794976 on dm-3 (992 sectors) [83609.763402]
btrfs-submit-1(693): WRITE block 247135144 on dm-3 (984 sectors)
[83609.763463] btrfs-submit-1(693): WRITE block 248796272 on dm-3 (984
sectors) [83609.763524] btrfs-submit-1(693): WRITE block 248826784 on
dm-3 (984 sectors) [83609.763585] btrfs-submit-1(693): WRITE block
248829352 on dm-3 (984 sectors) [83609.763589] btrfs-submit-1(693):
WRITE block 248934288 on dm-3 (32 sectors) [83609.763647]
btrfs-submit-1(693): WRITE block 248934320 on dm-3 (944 sectors)
[83609.763708] btrfs-submit-1(693): WRITE block 248935576 on dm-3 (976
sectors) [83609.763768] btrfs-submit-1(693): WRITE block 248946776 on
dm-3 (976 sectors) [83609.763832] btrfs-submit-1(693): WRITE block
248966128 on dm-3 (976 sectors) [83609.763902] btrfs-submit-1(693):
WRITE block 246988808 on dm-3 (968 sectors) [83609.763971]
btrfs-submit-1(693): WRITE block 248923424 on dm-3 (968 sectors)
[83609.764041] btrfs-submit-1(693): WRITE block 249008160 on dm-3 (968
sectors) [83609.764111] btrfs-submit-1(693): WRITE block 249084312 on
dm-3 (968 sectors) [83609.764201] btrfs-submit-1(693): WRITE block
249687824 on dm-3 (968 sectors) [83609.764297] btrfs-submit-1(693):
WRITE block 248526712 on dm-3 (960 sectors) [83609.764391]
btrfs-submit-1(693): WRITE block 249715776 on dm-3 (960 sectors)
[83609.764463] btrfs-submit-1(693): WRITE block 249765928 on dm-3 (960
sectors) [83609.764526] btrfs-submit-1(693): WRITE block 249775960 on
dm-3 (960 sectors) [83609.764587] btrfs-submit-1(693): WRITE block
249758144 on dm-3 (952 sectors) [83609.764648] btrfs-submit-1(693):
WRITE block 249759512 on dm-3 (952 sectors) [83609.764709]
btrfs-submit-1(693): WRITE block 249763568 on dm-3 (952 sectors)
[83609.764769] btrfs-submit-1(693): WRITE block 249764648 on dm-3 (952
sectors) [83609.764778] btrfs-submit-1(693): WRITE block 245701712 on
dm-3 (104 sectors) [83609.764834] btrfs-submit-1(693): WRITE block
245701816 on dm-3 (840 sectors) [83609.764894] btrfs-submit-1(693):
WRITE block 249770064 on dm-3 (944 sectors) [83609.764958]
btrfs-submit-1(693): WRITE block 249796976 on dm-3 (944 sectors)
[83609.765024] btrfs-submit-1(693): WRITE block 249798336 on dm-3 (944
sectors) [83609.765098] btrfs-submit-1(693): WRITE block 249812472 on
dm-3 (944 sectors) [83609.765180] btrfs-submit-1(693): WRITE block
246980792 on dm-3 (936 sectors) [83609.765270] btrfs-submit-1(693):
WRITE block 247781736 on dm-3 (936 sectors) [83609.765362]
btrfs-submit-1(693): WRITE block 247797656 on dm-3 (936 sectors)
[83609.765427] btrfs-submit-1(693): WRITE block 249816712 on dm-3 (936
sectors) [83609.765493] btrfs-submit-1(693): WRITE block 245545360 on
dm-3 (928 sectors) [83609.765557] btrfs-submit-1(693): WRITE block
247406160 on dm-3 (928 sectors) [83609.765621] btrfs-submit-1(693):
WRITE block 248950856 on dm-3 (928 sectors) [83609.765686]
btrfs-submit-1(693): WRITE block 249828728 on dm-3 (928 sectors)
[83609.765747] btrfs-submit-1(693): WRITE block 241578536 on dm-3 (920
sectors) [83609.765813] btrfs-submit-1(693): WRITE block 243982336 on
dm-3 (920 sectors) [83609.765878] btrfs-submit-1(693): WRITE block
246348848 on dm-3 (920 sectors) [83609.765945] btrfs-submit-1(693):
WRITE block 249835672 on dm-3 (920 sectors) [83609.765990]
btrfs-submit-1(693): WRITE block 249837040 on dm-3 (712 sectors)
[83609.766006] btrfs-submit-1(693): WRITE block 249837752 on dm-3 (208
sectors) [83609.766077] btrfs-submit-1(693): WRITE block 246994448 on
dm-3 (912 sectors) [83609.766145] btrfs-submit-1(693): WRITE block
247024808 on dm-3 (912 sectors) [83609.766233] btrfs-submit-1(693):
WRITE block 247796592 on dm-3 (912 sectors) [83609.766324]
btrfs-submit-1(693): WRITE block 249838400 on dm-3 (912 sectors)
[83609.766403] btrfs-submit-1(693): WRITE block 241393064 on dm-3 (904
sectors) [83609.766464] btrfs-submit-1(693): WRITE block 247305784 on
dm-3 (904 sectors) [83609.766524] btrfs-submit-1(693): WRITE block
247308376 on dm-3 (904 sectors) [83609.766587] btrfs-submit-1(693):
WRITE block 247744104 on dm-3 (904 sectors) [83609.766645]
btrfs-submit-1(693): WRITE block 248864968 on dm-3 (904 sectors)
[83609.766703] btrfs-submit-1(693): WRITE block 244657776 on dm-3 (896
sectors) [83609.766760] btrfs-submit-1(693): WRITE block 244788320 on
dm-3 (896 sectors) [83609.766818] btrfs-submit-1(693): WRITE block
247737000 on dm-3 (896 sectors) [83609.766874] btrfs-submit-1(693):
WRITE block 247754688 on dm-3 (896 sectors) [83609.766931]
btrfs-submit-1(693): WRITE block 248835640 on dm-3 (888 sectors)
[83609.766991] btrfs-submit-1(693): WRITE block 249875920 on dm-3 (888
sectors) [83609.767047] btrfs-submit-1(693): WRITE block 249670264 on
dm-3 (888 sectors) [83609.767110] btrfs-submit-1(693): WRITE block
249845312 on dm-3 (888 sectors) [83609.767189] btrfs-submit-1(693):
WRITE block 249950776 on dm-3 (888 sectors) [83609.767195]
btrfs-submit-1(693): WRITE block 245553640 on dm-3 (64 sectors)
[83609.767274] btrfs-submit-1(693): WRITE block 245553704 on dm-3 (816
sectors) [83609.767364] btrfs-submit-1(693): WRITE block 246872056 on
dm-3 (880 sectors) [83609.767434] btrfs-submit-1(693): WRITE block
249972040 on dm-3 (880 sectors) [83609.767499] btrfs-submit-1(693):
WRITE block 250063368 on dm-3 (880 sectors) [83609.767562]
btrfs-submit-1(693): WRITE block 250093896 on dm-3 (880 sectors)
[83609.767627] btrfs-submit-1(693): WRITE block 244662200 on dm-3 (872
sectors) [83609.767686] btrfs-submit-1(693): WRITE block 245599824 on
dm-3 (872 sectors) [83609.767748] btrfs-submit-1(693): WRITE block
247623640 on dm-3 (872 sectors) [83609.767807] btrfs-submit-1(693):
WRITE block 250252024 on dm-3 (872 sectors) [83609.767866]
btrfs-submit-1(693): WRITE block 245926216 on dm-3 (864 sectors)
[83609.767925] btrfs-submit-1(693): WRITE block 247627256 on dm-3 (864
sectors) [83609.767986] btrfs-submit-1(693): WRITE block 251649016 on
dm-3 (864 sectors) [83609.768047] btrfs-submit-1(693): WRITE block
251652832 on dm-3 (864 sectors) [83609.768108] btrfs-submit-1(693):
WRITE block 251666040 on dm-3 (864 sectors) [83609.768184]
btrfs-submit-1(693): WRITE block 245204888 on dm-3 (856 sectors)
[83609.768266] btrfs-submit-1(693): WRITE block 251862560 on dm-3 (856
sectors) [83609.768349] btrfs-submit-1(693): WRITE block 251863616 on
dm-3 (856 sectors) [83609.768411] btrfs-submit-1(693): WRITE block
251875176 on dm-3 (856 sectors) [83609.768465] btrfs-submit-1(693):
WRITE block 251885312 on dm-3 (856 sectors) [83609.768468]
btrfs-submit-1(693): WRITE block 245912200 on dm-3 (40 sectors)
[83609.768519] btrfs-submit-1(693): WRITE block 245912240 on dm-3 (808
sectors) [83609.768573] btrfs-submit-1(693): WRITE block 248199488 on
dm-3 (848 sectors) [83609.768626] btrfs-submit-1(693): WRITE block
248956488 on dm-3 (848 sectors) [83609.768683] btrfs-submit-1(693):
WRITE block 249847736 on dm-3 (848 sectors) [83609.768739]
btrfs-submit-1(693): WRITE block 251895008 on dm-3 (848 sectors)
[83609.768793] btrfs-submit-1(693): WRITE block 237927728 on dm-3 (840
sectors) [83609.768848] btrfs-submit-1(693): WRITE block 238156448 on
dm-3 (840 sectors) [83609.768902] btrfs-submit-1(693): WRITE block
238236416 on dm-3 (840 sectors) [83609.768962] btrfs-submit-1(693):
WRITE block 246824512 on dm-3 (840 sectors) [83609.769024]
btrfs-submit-1(693): WRITE block 246878232 on dm-3 (840 sectors)
[83609.769087] btrfs-submit-1(693): WRITE block 220692560 on dm-3 (832
sectors) [83609.769157] btrfs-submit-1(693): WRITE block 221230472 on
dm-3 (832 sectors) [83609.769241] btrfs-submit-1(693): WRITE block
221264752 on dm-3 (832 sectors) [83609.769323] btrfs-submit-1(693):
WRITE block 221360816 on dm-3 (832 sectors) [83609.769405]
btrfs-submit-1(693): WRITE block 219982232 on dm-3 (824 sectors)
[83609.769469] btrfs-submit-1(693): WRITE block 221161872 on dm-3 (824
sectors) [83609.769529] btrfs-submit-1(693): WRITE block 222923728 on
dm-3 (824 sectors) [83609.769590] btrfs-submit-1(693): WRITE block
229710024 on dm-3 (824 sectors) [83609.769650] btrfs-submit-1(693):
WRITE block 234247176 on dm-3 (824 sectors) [83609.769690]
btrfs-submit-1(693): WRITE block 212620224 on dm-3 (616 sectors)
[83609.769705] btrfs-submit-1(693): WRITE block 212620840 on dm-3 (200
sectors) [83609.769767] btrfs-submit-1(693): WRITE block 225232616 on
dm-3 (816 sectors) [83609.769827] btrfs-submit-1(693): WRITE block
230613200 on dm-3 (816 sectors) [83609.769879] btrfs-submit-1(693):
WRITE block 232086632 on dm-3 (816 sectors) [83609.769933]
btrfs-submit-1(693): WRITE block 234289856 on dm-3 (816 sectors)
[83609.769985] btrfs-submit-1(693): WRITE block 214768856 on dm-3 (808
sectors) [83609.770043] btrfs-submit-1(693): WRITE block 215806280 on
dm-3 (808 sectors) [83609.770102] btrfs-submit-1(693): WRITE block
219568528 on dm-3 (808 sectors) [83609.770175] btrfs-submit-1(693):
WRITE block 221010816 on dm-3 (808 sectors) [83609.770256]
btrfs-submit-1(693): WRITE block 228845920 on dm-3 (808 sectors)
[83609.770334] btrfs-submit-1(693): WRITE block 232386120 on dm-3 (808
sectors) [83609.770405] btrfs-submit-1(693): WRITE block 212596800 on
dm-3 (800 sectors) [83609.770461] btrfs-submit-1(693): WRITE block
215800304 on dm-3 (800 sectors) [83609.770517] btrfs-submit-1(693):
WRITE block 219445664 on dm-3 (800 sectors) [83609.770575]
btrfs-submit-1(693): WRITE block 220698944 on dm-3 (800 sectors)
[83609.770631] btrfs-submit-1(693): WRITE block 221125448 on dm-3 (800
sectors) [83609.770685] btrfs-submit-1(693): WRITE block 213449000 on
dm-3 (792 sectors) [83609.770741] btrfs-submit-1(693): WRITE block
214892936 on dm-3 (792 sectors) [83609.770795] btrfs-submit-1(693):
WRITE block 219552784 on dm-3 (792 sectors) [83609.770853]
btrfs-submit-1(693): WRITE block 221029312 on dm-3 (792 sectors)
[83609.770908] btrfs-submit-1(693): WRITE block 221514728 on dm-3 (792
sectors) [83609.770923] btrfs-submit-1(693): WRITE block 213839680 on
dm-3 (192 sectors) [83609.770961] btrfs-submit-1(693): WRITE block
213839872 on dm-3 (592 sectors) [83609.771021] btrfs-submit-1(693):
WRITE block 214081256 on dm-3 (784 sectors) [83609.771079]
btrfs-submit-1(693): WRITE block 220748568 on dm-3 (784 sectors)
[83609.771139] btrfs-submit-1(693): WRITE block 221421560 on dm-3 (784
sectors) [83609.771219] btrfs-submit-1(693): WRITE block 223267208 on
dm-3 (784 sectors) [83609.771296] btrfs-submit-1(693): WRITE block
213422752 on dm-3 (776 sectors) [83609.771375] btrfs-submit-1(693):
WRITE block 221041952 on dm-3 (776 sectors) [83609.771440]
btrfs-submit-1(693): WRITE block 221279280 on dm-3 (776 sectors)
[83609.771495] btrfs-submit-1(693): WRITE block 229372912 on dm-3 (776
sectors) [83609.771550] btrfs-submit-1(693): WRITE block 230109896 on
dm-3 (776 sectors) [83609.771602] btrfs-submit-1(693): WRITE block
220696840 on dm-3 (768 sectors) [83609.771656] btrfs-submit-1(693):
WRITE block 220722136 on dm-3 (768 sectors) [83609.771711]
btrfs-submit-1(693): WRITE block 221124440 on dm-3 (768 sectors)
[83609.771767] btrfs-submit-1(693): WRITE block 221302624 on dm-3 (768
sectors) [83609.771820] btrfs-submit-1(693): WRITE block 221706248 on
dm-3 (768 sectors) [83609.771875] btrfs-submit-1(693): WRITE block
230044136 on dm-3 (768 sectors) [83609.771924] btrfs-submit-1(693):
WRITE block 217231112 on dm-3 (760 sectors) [83609.771979]
btrfs-submit-1(693): WRITE block 220700840 on dm-3 (760 sectors)
[83609.772028] btrfs-submit-1(693): WRITE block 230060688 on dm-3 (760
sectors) [83609.772088] btrfs-submit-1(693): WRITE block 232766728 on
dm-3 (760 sectors) [83609.772154] btrfs-submit-1(693): WRITE block
232909504 on dm-3 (760 sectors) [83609.772184] btrfs-submit-1(693):
WRITE block 221089504 on dm-3 (448 sectors) [83609.772206]
btrfs-submit-1(693): WRITE block 221089952 on dm-3 (304 sectors)
[83609.772306] btrfs-submit-1(693): WRITE block 221232400 on dm-3 (752
sectors) [83609.772382] btrfs-submit-1(693): WRITE block 233000736 on
dm-3 (752 sectors) [83609.772437] btrfs-submit-1(693): WRITE block
233445304 on dm-3 (752 sectors) [83609.772489] btrfs-submit-1(693):
WRITE block 233524720 on dm-3 (752 sectors) [83609.772542]
btrfs-submit-1(693): WRITE block 213438896 on dm-3 (744 sectors)
[83609.772595] btrfs-submit-1(693): WRITE block 214027784 on dm-3 (744
sectors) [83609.772648] btrfs-submit-1(693): WRITE block 220731152 on
dm-3 (744 sectors) [83609.772701] btrfs-submit-1(693): WRITE block
221194016 on dm-3 (744 sectors) [83609.772752] btrfs-submit-1(693):
WRITE block 221201472 on dm-3 (744 sectors) [83609.772808]
btrfs-submit-1(693): WRITE block 221299640 on dm-3 (744 sectors)
[83609.772859] btrfs-submit-1(693): WRITE block 212597736 on dm-3 (736
sectors) [83609.772913] btrfs-submit-1(693): WRITE block 216398328 on
dm-3 (736 sectors) [83609.772964] btrfs-submit-1(693): WRITE block
217399864 on dm-3 (736 sectors) [83609.773012] btrfs-submit-1(693):
WRITE block 221063376 on dm-3 (736 sectors) [83609.773071]
btrfs-submit-1(693): WRITE block 221163040 on dm-3 (736 sectors)
[83609.773125] btrfs-submit-1(693): WRITE block 218030024 on dm-3 (728
sectors) [83609.773198] btrfs-submit-1(693): WRITE block 221122416 on
dm-3 (728 sectors) [83609.773269] btrfs-submit-1(693): WRITE block
221435944 on dm-3 (728 sectors) [83609.773341] btrfs-submit-1(693):
WRITE block 221453624 on dm-3 (728 sectors) [83609.773408]
btrfs-submit-1(693): WRITE block 223253744 on dm-3 (728 sectors)
[83609.773461] btrfs-submit-1(693): WRITE block 231863616 on dm-3 (728
sectors) [83609.773503] btrfs-submit-1(693): WRITE block 212580304 on
dm-3 (640 sectors) [83609.773510] btrfs-submit-1(693): WRITE block
212580944 on dm-3 (80 sectors) [83609.773567] btrfs-submit-1(693):
WRITE block 219646488 on dm-3 (720 sectors) [83609.773617]
btrfs-submit-1(693): WRITE block 219792520 on dm-3 (720 sectors)
[83609.773669] btrfs-submit-1(693): WRITE block 220681992 on dm-3 (720
sectors) [83609.773722] btrfs-submit-1(693): WRITE block 220708312 on
dm-3 (720 sectors) [83609.773775] btrfs-submit-1(693): WRITE block
221017744 on dm-3 (720 sectors) [83609.773823] btrfs-submit-1(693):
WRITE block 212582816 on dm-3 (712 sectors) [83609.773875]
btrfs-submit-1(693): WRITE block 215712024 on dm-3 (712 sectors)
[83609.773920] btrfs-submit-1(693): WRITE block 221287088 on dm-3 (712
sectors) [83609.773965] btrfs-submit-1(693): WRITE block 221465352 on
dm-3 (712 sectors) [83609.774011] btrfs-submit-1(693): WRITE block
230639232 on dm-3 (712 sectors) [83609.774062] btrfs-submit-1(693):
WRITE block 232388888 on dm-3 (712 sectors) [83609.774107]
btrfs-submit-1(693): WRITE block 212704912 on dm-3 (704 sectors)
[83609.774159] btrfs-submit-1(693): WRITE block 212863064 on dm-3 (704
sectors) [83609.774226] btrfs-submit-1(693): WRITE block 212864400 on
dm-3 (704 sectors) [83609.774294] btrfs-submit-1(693): WRITE block
216003120 on dm-3 (704 sectors) [83609.774365] btrfs-submit-1(693):
WRITE block 216478312 on dm-3 (704 sectors) [83609.774438]
btrfs-submit-1(693): WRITE block 213344056 on dm-3 (696 sectors)
[83609.774494] btrfs-submit-1(693): WRITE block 213958496 on dm-3 (696
sectors) [83609.774542] btrfs-submit-1(693): WRITE block 215826632 on
dm-3 (696 sectors) [83609.774596] btrfs-submit-1(693): WRITE block
217131000 on dm-3 (696 sectors) [83609.774645] btrfs-submit-1(693):
WRITE block 217152416 on dm-3 (696 sectors) [83609.774696]
btrfs-submit-1(693): WRITE block 217514744 on dm-3 (696 sectors)
[83609.774746] btrfs-submit-1(693): WRITE block 212679752 on dm-3 (688
sectors) [83609.774757] btrfs-submit-1(693): WRITE block 213210680 on
dm-3 (128 sectors) [83609.774793] btrfs-submit-1(693): WRITE block
213210808 on dm-3 (560 sectors) [83609.774850] btrfs-submit-1(693):
WRITE block 213252984 on dm-3 (688 sectors) [83609.774899]
btrfs-submit-1(693): WRITE block 213339464 on dm-3 (688 sectors)
[83609.774951] btrfs-submit-1(693): WRITE block 214199832 on dm-3 (688
sectors) [83609.774999] btrfs-submit-1(693): WRITE block 214679304 on
dm-3 (688 sectors) [83609.775048] btrfs-submit-1(693): WRITE block
213013072 on dm-3 (680 sectors) [83609.775099] btrfs-submit-1(693):
WRITE block 213648248 on dm-3 (680 sectors) [83609.775165]
btrfs-submit-1(693): WRITE block 215368816 on dm-3 (680 sectors)
[83609.775231] btrfs-submit-1(693): WRITE block 215751832 on dm-3 (680
sectors) [83609.775298] btrfs-submit-1(693): WRITE block 217959120 on
dm-3 (680 sectors) [83609.775366] btrfs-submit-1(693): WRITE block
219494272 on dm-3 (680 sectors) [83609.775428] btrfs-submit-1(693):
WRITE block 209615664 on dm-3 (672 sectors) [83609.775477]
btrfs-submit-1(693): WRITE block 209980952 on dm-3 (672 sectors)
[83609.775524] btrfs-submit-1(693): WRITE block 210590760 on dm-3 (672
sectors) [83609.775573] btrfs-submit-1(693): WRITE block 211128104 on
dm-3 (672 sectors) [83609.775622] btrfs-submit-1(693): WRITE block
211592920 on dm-3 (672 sectors) [83609.775666] btrfs-submit-1(693):
WRITE block 211815112 on dm-3 (672 sectors) [83609.775715]
btrfs-submit-1(693): WRITE block 208033952 on dm-3 (664 sectors)
[83609.775761] btrfs-submit-1(693): WRITE block 208997168 on dm-3 (664
sectors) [83609.775807] btrfs-submit-1(693): WRITE block 209408872 on
dm-3 (664 sectors) [83609.775854] btrfs-submit-1(693): WRITE block
211961888 on dm-3 (664 sectors) [83609.775900] btrfs-submit-1(693):
WRITE block 212125568 on dm-3 (664 sectors) [83609.775946]
btrfs-submit-1(693): WRITE block 212396536 on dm-3 (664 sectors)
[83609.775994] btrfs-submit-1(693): WRITE block 207929824 on dm-3 (656
sectors) [83609.776022] btrfs-submit-1(693): WRITE block 209345848 on
dm-3 (400 sectors) [83609.776041] btrfs-submit-1(693): WRITE block
209346248 on dm-3 (256 sectors) [83609.776097] btrfs-submit-1(693):
WRITE block 211560840 on dm-3 (656 sectors) [83609.776161]
btrfs-submit-1(693): WRITE block 212195720 on dm-3 (656 sectors)
[83609.776226] btrfs-submit-1(693): WRITE block 212394352 on dm-3 (656
sectors) [83609.776293] btrfs-submit-1(693): WRITE block 213006320 on
dm-3 (656 sectors) [83609.776360] btrfs-submit-1(693): WRITE block
213268432 on dm-3 (656 sectors) [83609.776426] btrfs-submit-1(693):
WRITE block 201696128 on dm-3 (648 sectors) [83609.776484]
btrfs-submit-1(693): WRITE block 202801520 on dm-3 (648 sectors)
[83609.776528] btrfs-submit-1(693): WRITE block 206214248 on dm-3 (648
sectors) [83609.776570] btrfs-submit-1(693): WRITE block 206599216 on
dm-3 (648 sectors) [83609.776614] btrfs-submit-1(693): WRITE block
206993280 on dm-3 (648 sectors) [83609.776660] btrfs-submit-1(693):
WRITE block 207113672 on dm-3 (648 sectors) [83609.776703]
btrfs-submit-1(693): WRITE block 200457440 on dm-3 (640 sectors)
[83609.776750] btrfs-submit-1(693): WRITE block 203108336 on dm-3 (640
sectors) [83609.776797] btrfs-submit-1(693): WRITE block 205781288 on
dm-3 (640 sectors) [83609.776842] btrfs-submit-1(693): WRITE block
206212104 on dm-3 (640 sectors) [83609.776884] btrfs-submit-1(693):
WRITE block 206695192 on dm-3 (640 sectors) [83609.776930]
btrfs-submit-1(693): WRITE block 207710696 on dm-3 (640 sectors)
[83609.776975] btrfs-submit-1(693): WRITE block 202510696 on dm-3 (632
sectors) [83609.777019] btrfs-submit-1(693): WRITE block 205448536 on
dm-3 (632 sectors) [83609.777090] btrfs-submit-1(693): WRITE block
206060616 on dm-3 (632 sectors) [83609.777118] btrfs-submit-1(693):
WRITE block 206190120 on dm-3 (632 sectors) [83609.777182]
btrfs-submit-1(693): WRITE block 206209888 on dm-3 (632 sectors)
[83609.777244] btrfs-submit-1(693): WRITE block 208069736 on dm-3 (632
sectors) [83609.777308] btrfs-submit-1(693): WRITE block 208094040 on
dm-3 (632 sectors) [83609.777368] btrfs-submit-1(693): WRITE block
201202768 on dm-3 (624 sectors) [83609.777379] btrfs-submit-1(693):
WRITE block 201357064 on dm-3 (152 sectors) [83609.777422]
btrfs-submit-1(693): WRITE block 201357216 on dm-3 (472 sectors)
[83609.777481] btrfs-submit-1(693): WRITE block 204192840 on dm-3 (624
sectors) [83609.777526] btrfs-submit-1(693): WRITE block 204577312 on
dm-3 (624 sectors) [83609.777567] btrfs-submit-1(693): WRITE block
206183504 on dm-3 (624 sectors) [83609.777608] btrfs-submit-1(693):
WRITE block 206237592 on dm-3 (624 sectors) [83609.777648]
btrfs-submit-1(693): WRITE block 200460960 on dm-3 (616 sectors)
[83609.777688] btrfs-submit-1(693): WRITE block 203968024 on dm-3 (616
sectors) [83609.777727] btrfs-submit-1(693): WRITE block 204280680 on
dm-3 (616 sectors) [83609.777767] btrfs-submit-1(693): WRITE block
206213224 on dm-3 (616 sectors) [83609.777807] btrfs-submit-1(693):
WRITE block 206281832 on dm-3 (616 sectors) [83609.777847]
btrfs-submit-1(693): WRITE block 207776096 on dm-3 (616 sectors)
[83609.777886] btrfs-submit-1(693): WRITE block 208890408 on dm-3 (616
sectors) [83609.777926] btrfs-submit-1(693): WRITE block 198514104 on
dm-3 (608 sectors) [83609.777965] btrfs-submit-1(693): WRITE block
201061744 on dm-3 (608 sectors) [83609.778005] btrfs-submit-1(693):
WRITE block 205912736 on dm-3 (608 sectors) [83609.778048]
btrfs-submit-1(693): WRITE block 206068976 on dm-3 (608 sectors)
[83609.778096] btrfs-submit-1(693): WRITE block 207099144 on dm-3 (608
sectors) [83609.778135] btrfs-submit-1(693): WRITE block 207484112 on
dm-3 (608 sectors) [83609.778196] btrfs-submit-1(693): WRITE block
208897960 on dm-3 (608 sectors) [83609.778258] btrfs-submit-1(693):
WRITE block 198581592 on dm-3 (600 sectors) [83609.778315]
btrfs-submit-1(693): WRITE block 200477520 on dm-3 (600 sectors)
[83609.778376] btrfs-submit-1(693): WRITE block 201516576 on dm-3 (600
sectors) [83609.778435] btrfs-submit-1(693): WRITE block 204216152 on
dm-3 (600 sectors) [83609.778482] btrfs-submit-1(693): WRITE block
205784208 on dm-3 (600 sectors) [83609.778521] btrfs-submit-1(693):
WRITE block 205966616 on dm-3 (600 sectors) [83609.778561]
btrfs-submit-1(693): WRITE block 206126256 on dm-3 (600 sectors)
[83609.778599] btrfs-submit-1(693): WRITE block 189774192 on dm-3 (592
sectors) [83609.778610] btrfs-submit-1(693): WRITE block 190584880 on
dm-3 (136 sectors) [83609.778640] btrfs-submit-1(693): WRITE block
190585016 on dm-3 (456 sectors) [83609.778688] btrfs-submit-1(693):
WRITE block 190997528 on dm-3 (592 sectors) [83609.778732]
btrfs-submit-1(693): WRITE block 193500000 on dm-3 (592 sectors)
[83609.778774] btrfs-submit-1(693): WRITE block 194140352 on dm-3 (592
sectors) [83609.778817] btrfs-submit-1(693): WRITE block 194868672 on
dm-3 (592 sectors) [83609.778857] btrfs-submit-1(693): WRITE block
195483184 on dm-3 (592 sectors) [83609.778896] btrfs-submit-1(693):
WRITE block 126070872 on dm-3 (584 sectors) [83609.778936]
btrfs-submit-1(693): WRITE block 126107272 on dm-3 (584 sectors)
[83609.778975] btrfs-submit-1(693): WRITE block 126172456 on dm-3 (584
sectors) [83609.779015] btrfs-submit-1(693): WRITE block 127934912 on
dm-3 (584 sectors) [83609.779061] btrfs-submit-1(693): WRITE block
134387712 on dm-3 (584 sectors) [83609.779098] btrfs-submit-1(693):
WRITE block 137042472 on dm-3 (584 sectors) [83609.779149]
btrfs-submit-1(693): WRITE block 137493384 on dm-3 (584 sectors)
[83609.779228] btrfs-submit-1(693): WRITE block 73746408 on dm-3 (576
sectors) [83609.779268] btrfs-submit-1(693): WRITE block 77647504 on
dm-3 (576 sectors) [83609.779328] btrfs-submit-1(693): WRITE block
81880608 on dm-3 (576 sectors) [83609.779387] btrfs-submit-1(693):
WRITE block 83517152 on dm-3 (576 sectors) [83609.779444]
btrfs-submit-1(693): WRITE block 84016288 on dm-3 (576 sectors)
[83609.779498] btrfs-submit-1(693): WRITE block 94425184 on dm-3 (576
sectors) [83609.779541] btrfs-submit-1(693): WRITE block 94965832 on
dm-3 (576 sectors) [83609.779582] btrfs-submit-1(693): WRITE block
75720968 on dm-3 (568 sectors) [83609.779627] btrfs-submit-1(693):
WRITE block 76722152 on dm-3 (568 sectors) [83609.779667]
btrfs-submit-1(693): WRITE block 79768488 on dm-3 (568 sectors)
[83609.779710] btrfs-submit-1(693): WRITE block 80408856 on dm-3 (568
sectors) [83609.779751] btrfs-submit-1(693): WRITE block 82443816 on
dm-3 (568 sectors) [83609.779791] btrfs-submit-1(693): WRITE block
82555864 on dm-3 (568 sectors) [83609.779833] btrfs-submit-1(693):
WRITE block 88472016 on dm-3 (568 sectors) [83609.779871]
btrfs-submit-1(693): WRITE block 51030360 on dm-3 (560 sectors)
[83609.779898] btrfs-submit-1(693): WRITE block 54438448 on dm-3 (392
sectors) [83609.779911] btrfs-submit-1(693): WRITE block 54438840 on
dm-3 (168 sectors) [83609.779956] btrfs-submit-1(693): WRITE block
54980456 on dm-3 (560 sectors) [83609.779994] btrfs-submit-1(693):
WRITE block 55891816 on dm-3 (560 sectors) [83609.780032]
btrfs-submit-1(693): WRITE block 61812944 on dm-3 (560 sectors)
[83609.780076] btrfs-submit-1(693): WRITE block 63700048 on dm-3 (560
sectors) [83609.780112] btrfs-submit-1(693): WRITE block 63944144 on
dm-3 (560 sectors) [83609.780230] btrfs-submit-1(693): WRITE block
340215080 on dm-3 (1024 sectors) [83609.780238] btrfs-submit-1(693):
WRITE block 340216104 on dm-3 (88 sectors) [83609.780338]
btrfs-submit-1(693): WRITE block 356868984 on dm-3 (1024 sectors)
[83609.780345] btrfs-submit-1(693): WRITE block 356870008 on dm-3 (88
sectors) [83609.780447] btrfs-submit-1(693): WRITE block 338409728 on
dm-3 (1024 sectors) [83609.780454] btrfs-submit-1(693): WRITE block
338410752 on dm-3 (80 sectors) [83609.780532] btrfs-submit-1(693):
WRITE block 356558360 on dm-3 (1024 sectors) [83609.780539]
btrfs-submit-1(693): WRITE block 356559384 on dm-3 (80 sectors)
[83609.780614] btrfs-submit-1(693): WRITE block 338380160 on dm-3
(1024 sectors) [83609.780621] btrfs-submit-1(693): WRITE block
338381184 on dm-3 (72 sectors) [83609.780692] btrfs-submit-1(693):
WRITE block 356507872 on dm-3 (1024 sectors) [83609.780698]
btrfs-submit-1(693): WRITE block 356508896 on dm-3 (72 sectors)
[83609.780780] btrfs-submit-1(693): WRITE block 331932224 on dm-3
(1024 sectors) [83609.780786] btrfs-submit-1(693): WRITE block
331933248 on dm-3 (64 sectors) [83609.780855] btrfs-submit-1(693):
WRITE block 335522504 on dm-3 (1024 sectors) [83609.780861]
btrfs-submit-1(693): WRITE block 335523528 on dm-3 (64 sectors)
[83609.780936] btrfs-submit-1(693): WRITE block 321537296 on dm-3
(1024 sectors) [83609.780940] btrfs-submit-1(693): WRITE block
321538320 on dm-3 (56 sectors) [83609.781014] btrfs-submit-1(693):
WRITE block 328814024 on dm-3 (1024 sectors) [83609.781019]
btrfs-submit-1(693): WRITE block 328815048 on dm-3 (56 sectors)
[83609.781100] btrfs-submit-1(693): WRITE block 321220672 on dm-3
(1024 sectors) [83609.781104] btrfs-submit-1(693): WRITE block
321221696 on dm-3 (48 sectors) [83609.781191] btrfs-submit-1(693):
WRITE block 327747888 on dm-3 (1024 sectors) [83609.781195]
btrfs-submit-1(693): WRITE block 327748912 on dm-3 (48 sectors)
[83609.781223] btrfs-submit-1(693): WRITE block 324505640 on dm-3 (392
sectors) [83609.781282] btrfs-submit-1(693): WRITE block 324506032 on
dm-3 (672 sectors) [83609.781400] btrfs-submit-1(693): WRITE block
315328560 on dm-3 (1024 sectors) [83609.781404] btrfs-submit-1(693):
WRITE block 315329584 on dm-3 (32 sectors) [83609.781503]
btrfs-submit-1(693): WRITE block 323165424 on dm-3 (1024 sectors)
[83609.781506] btrfs-submit-1(693): WRITE block 323166448 on dm-3 (32
sectors) [83609.781581] btrfs-submit-1(693): WRITE block 315028336 on
dm-3 (1024 sectors) [83609.781584] btrfs-submit-1(693): WRITE block
315029360 on dm-3 (24 sectors) [83609.781654] btrfs-submit-1(693):
WRITE block 319631160 on dm-3 (1024 sectors) [83609.781658]
btrfs-submit-1(693): WRITE block 319632184 on dm-3 (24 sectors)
[83609.781725] btrfs-submit-1(693): WRITE block 286265464 on dm-3
(1024 sectors) [83609.781728] btrfs-submit-1(693): WRITE block
286266488 on dm-3 (16 sectors) [83609.781793] btrfs-submit-1(693):
WRITE block 294823528 on dm-3 (1024 sectors) [83609.781796]
btrfs-submit-1(693): WRITE block 294824552 on dm-3 (16 sectors)
[83609.781863] btrfs-submit-1(693): WRITE block 252504656 on dm-3
(1024 sectors) [83609.781866] btrfs-submit-1(693): WRITE block
252505680 on dm-3 (8 sectors) [83609.781931] btrfs-submit-1(693):
WRITE block 257237656 on dm-3 (1024 sectors) [83609.781935]
btrfs-submit-1(693): WRITE block 257238680 on dm-3 (8 sectors)
[83609.781998] btrfs-submit-1(693): WRITE block 251898696 on dm-3
(1024 sectors) [83609.782093] btrfs-submit-1(693): WRITE block
251929176 on dm-3 (1024 sectors) [83609.782140] btrfs-submit-1(693):
WRITE block 251934624 on dm-3 (1016 sectors) [83609.782223]
btrfs-submit-1(693): WRITE block 251938152 on dm-3 (1016 sectors)
[83609.782319] btrfs-submit-1(693): WRITE block 251950872 on dm-3
(1008 sectors) [83609.782417] btrfs-submit-1(693): WRITE block
252557024 on dm-3 (1008 sectors) [83609.782495] btrfs-submit-1(693):
WRITE block 252578264 on dm-3 (1000 sectors) [83609.782520]
btrfs-submit-1(693): WRITE block 252899552 on dm-3 (344 sectors)
[83609.782562] btrfs-submit-1(693): WRITE block 252899896 on dm-3 (656
sectors) [83609.782640] btrfs-submit-1(693): WRITE block 252902744 on
dm-3 (992 sectors) [83609.782716] btrfs-submit-1(693): WRITE block
252979952 on dm-3 (992 sectors) [83609.782786] btrfs-submit-1(693):
WRITE block 253107208 on dm-3 (984 sectors) [83609.782855]
btrfs-submit-1(693): WRITE block 253142000 on dm-3 (984 sectors)
[83609.782923] btrfs-submit-1(693): WRITE block 253293488 on dm-3 (984
sectors) [83609.782993] btrfs-submit-1(693): WRITE block 253821920 on
dm-3 (976 sectors) [83609.783069] btrfs-submit-1(693): WRITE block
253831672 on dm-3 (976 sectors) [83609.783140] btrfs-submit-1(693):
WRITE block 253837656 on dm-3 (968 sectors) [83609.783234]
btrfs-submit-1(693): WRITE block 253986472 on dm-3 (968 sectors)
[83609.783330] btrfs-submit-1(693): WRITE block 254215752 on dm-3 (960
sectors) [83609.783401] btrfs-submit-1(693): WRITE block 255121920 on
dm-3 (960 sectors) [83609.783461] btrfs-submit-1(693): WRITE block
255304272 on dm-3 (952 sectors) [83609.783521] btrfs-submit-1(693):
WRITE block 255405920 on dm-3 (952 sectors) [83609.783582]
btrfs-submit-1(693): WRITE block 255471056 on dm-3 (944 sectors)
[83609.783640] btrfs-submit-1(693): WRITE block 255531936 on dm-3 (944
sectors) [83609.783700] btrfs-submit-1(693): WRITE block 255888600 on
dm-3 (936 sectors) [83609.783723] btrfs-submit-1(693): WRITE block
255917696 on dm-3 (336 sectors) [83609.783763] btrfs-submit-1(693):
WRITE block 255918032 on dm-3 (600 sectors) [83609.783823]
btrfs-submit-1(693): WRITE block 255707512 on dm-3 (928 sectors)
[83609.783882] btrfs-submit-1(693): WRITE block 256666488 on dm-3 (928
sectors) [83609.783941] btrfs-submit-1(693): WRITE block 256711680 on
dm-3 (928 sectors) [83609.784000] btrfs-submit-1(693): WRITE block
256738448 on dm-3 (920 sectors) [83609.784081] btrfs-submit-1(693):
WRITE block 256873440 on dm-3 (920 sectors) [83609.784121]
btrfs-submit-1(693): WRITE block 257028920 on dm-3 (912 sectors)
[83609.784196] btrfs-submit-1(693): WRITE block 257084520 on dm-3 (912
sectors) [83609.784285] btrfs-submit-1(693): WRITE block 255327792 on
dm-3 (904 sectors) [83609.784373] btrfs-submit-1(693): WRITE block
257579600 on dm-3 (904 sectors) [83609.784448] btrfs-submit-1(693):
WRITE block 259799480 on dm-3 (896 sectors) [83609.784509]
btrfs-submit-1(693): WRITE block 259840760 on dm-3 (896 sectors)
[83609.784574] btrfs-submit-1(693): WRITE block 259903568 on dm-3 (896
sectors) [83609.784635] btrfs-submit-1(693): WRITE block 252887552 on
dm-3 (888 sectors) [83609.784698] btrfs-submit-1(693): WRITE block
260045688 on dm-3 (888 sectors) [83609.784762] btrfs-submit-1(693):
WRITE block 257262000 on dm-3 (880 sectors) [83609.784825]
btrfs-submit-1(693): WRITE block 259499216 on dm-3 (880 sectors)
[83609.784888] btrfs-submit-1(693): WRITE block 260111888 on dm-3 (872
sectors) [83609.784922] btrfs-submit-1(693): WRITE block 260312088 on
dm-3 (512 sectors) [83609.784947] btrfs-submit-1(693): WRITE block
260312600 on dm-3 (360 sectors) [83609.785016] btrfs-submit-1(693):
WRITE block 260352064 on dm-3 (872 sectors) [83609.785084]
btrfs-submit-1(693): WRITE block 260149912 on dm-3 (864 sectors)
[83609.785157] btrfs-submit-1(693): WRITE block 260379976 on dm-3 (864
sectors) [83609.785241] btrfs-submit-1(693): WRITE block 259353656 on
dm-3 (856 sectors) [83609.785326] btrfs-submit-1(693): WRITE block
260353880 on dm-3 (856 sectors) [83609.785398] btrfs-submit-1(693):
WRITE block 254309560 on dm-3 (848 sectors) [83609.785460]
btrfs-submit-1(693): WRITE block 259861640 on dm-3 (848 sectors)
[83609.785521] btrfs-submit-1(693): WRITE block 260593424 on dm-3 (848
sectors) [83609.785582] btrfs-submit-1(693): WRITE block 252850480 on
dm-3 (840 sectors) [83609.785643] btrfs-submit-1(693): WRITE block
253996856 on dm-3 (840 sectors) [83609.785703] btrfs-submit-1(693):
WRITE block 234317056 on dm-3 (832 sectors) [83609.785783]
btrfs-submit-1(693): WRITE block 244415952 on dm-3 (832 sectors)
[83609.785827] btrfs-submit-1(693): WRITE block 249689368 on dm-3 (832
sectors) [83609.785887] btrfs-submit-1(693): WRITE block 238278248 on
dm-3 (824 sectors) [83609.785948] btrfs-submit-1(693): WRITE block
239765432 on dm-3 (824 sectors) [83609.786005] btrfs-submit-1(693):
WRITE block 236125920 on dm-3 (816 sectors) [83609.786072]
btrfs-submit-1(693): WRITE block 239815840 on dm-3 (816 sectors)
[83609.786135] btrfs-submit-1(693): WRITE block 239835784 on dm-3 (816
sectors) [83609.786216] btrfs-submit-1(693): WRITE block 239843824 on
dm-3 (808 sectors) [83609.786229] btrfs-submit-1(693): WRITE block
239909520 on dm-3 (168 sectors) [83609.786290] btrfs-submit-1(693):
WRITE block 239909688 on dm-3 (640 sectors) [83609.786376]
btrfs-submit-1(693): WRITE block 237119384 on dm-3 (800 sectors)
[83609.786437] btrfs-submit-1(693): WRITE block 240458120 on dm-3 (800
sectors) [83609.786488] btrfs-submit-1(693): WRITE block 240729624 on
dm-3 (800 sectors) [83609.786540] btrfs-submit-1(693): WRITE block
237255856 on dm-3 (792 sectors) [83609.786593] btrfs-submit-1(693):
WRITE block 237636624 on dm-3 (792 sectors) [83609.786645]
btrfs-submit-1(693): WRITE block 233998064 on dm-3 (784 sectors)
[83609.786697] btrfs-submit-1(693): WRITE block 241390840 on dm-3 (784
sectors) [83609.786747] btrfs-submit-1(693): WRITE block 241477776 on
dm-3 (784 sectors) [83609.786797] btrfs-submit-1(693): WRITE block
242818288 on dm-3 (776 sectors) [83609.786847] btrfs-submit-1(693):
WRITE block 243517072 on dm-3 (776 sectors) [83609.786899]
btrfs-submit-1(693): WRITE block 241820056 on dm-3 (768 sectors)
[83609.786949] btrfs-submit-1(693): WRITE block 243961648 on dm-3 (768
sectors) [83609.786999] btrfs-submit-1(693): WRITE block 244888296 on
dm-3 (768 sectors) [83609.787048] btrfs-submit-1(693): WRITE block
233983264 on dm-3 (760 sectors) [83609.787101] btrfs-submit-1(693):
WRITE block 236944008 on dm-3 (760 sectors) [83609.787151]
btrfs-submit-1(693): WRITE block 238139768 on dm-3 (760 sectors)
[83609.787217] btrfs-submit-1(693): WRITE block 234348048 on dm-3 (752
sectors) [83609.787290] btrfs-submit-1(693): WRITE block 238099376 on
dm-3 (752 sectors) [83609.787365] btrfs-submit-1(693): WRITE block
238167968 on dm-3 (752 sectors) [83609.787432] btrfs-submit-1(693):
WRITE block 236851168 on dm-3 (744 sectors) [83609.787457]
btrfs-submit-1(693): WRITE block 240820552 on dm-3 (352 sectors)
[83609.787484] btrfs-submit-1(693): WRITE block 240820904 on dm-3 (392
sectors) [83609.787538] btrfs-submit-1(693): WRITE block 240814008 on
dm-3 (736 sectors) [83609.787592] btrfs-submit-1(693): WRITE block
241442280 on dm-3 (736 sectors) [83609.787646] btrfs-submit-1(693):
WRITE block 244444200 on dm-3 (736 sectors) [83609.787698]
btrfs-submit-1(693): WRITE block 233441672 on dm-3 (728 sectors)
[83609.787751] btrfs-submit-1(693): WRITE block 236200200 on dm-3 (728
sectors) [83609.787803] btrfs-submit-1(693): WRITE block 236267392 on
dm-3 (728 sectors) [83609.787856] btrfs-submit-1(693): WRITE block
233506424 on dm-3 (720 sectors) [83609.787904] btrfs-submit-1(693):
WRITE block 236749768 on dm-3 (720 sectors) [83609.787956]
btrfs-submit-1(693): WRITE block 237100712 on dm-3 (720 sectors)
[83609.788009] btrfs-submit-1(693): WRITE block 237217080 on dm-3 (712
sectors) [83609.788064] btrfs-submit-1(693): WRITE block 241308200 on
dm-3 (712 sectors) [83609.788120] btrfs-submit-1(693): WRITE block
241480272 on dm-3 (712 sectors) [83609.788188] btrfs-submit-1(693):
WRITE block 219804168 on dm-3 (704 sectors) [83609.788262]
btrfs-submit-1(693): WRITE block 220702288 on dm-3 (704 sectors)
[83609.788333] btrfs-submit-1(693): WRITE block 221370904 on dm-3 (704
sectors) [83609.788403] btrfs-submit-1(693): WRITE block 219969208 on
dm-3 (696 sectors) [83609.788461] btrfs-submit-1(693): WRITE block
221084304 on dm-3 (696 sectors) [83609.788511] btrfs-submit-1(693):
WRITE block 221523440 on dm-3 (688 sectors) [83609.788560]
btrfs-submit-1(693): WRITE block 223103488 on dm-3 (688 sectors)
[83609.788610] btrfs-submit-1(693): WRITE block 223240248 on dm-3 (688
sectors) [83609.788657] btrfs-submit-1(693): WRITE block 220710552 on
dm-3 (680 sectors) [83609.788706] btrfs-submit-1(693): WRITE block
220726944 on dm-3 (680 sectors) [83609.788737] btrfs-submit-1(693):
WRITE block 221009280 on dm-3 (456 sectors) [83609.788753]
btrfs-submit-1(693): WRITE block 221009736 on dm-3 (224 sectors)
[83609.788806] btrfs-submit-1(693): WRITE block 213425288 on dm-3 (672
sectors) [83609.788854] btrfs-submit-1(693): WRITE block 216159024 on
dm-3 (672 sectors) [83609.788904] btrfs-submit-1(693): WRITE block
220629224 on dm-3 (672 sectors) [83609.788951] btrfs-submit-1(693):
WRITE block 215079960 on dm-3 (664 sectors) [83609.789000]
btrfs-submit-1(693): WRITE block 216483856 on dm-3 (664 sectors)
[83609.789049] btrfs-submit-1(693): WRITE block 218056328 on dm-3 (664
sectors) [83609.789099] btrfs-submit-1(693): WRITE block 219953392 on
dm-3 (664 sectors) [83609.789165] btrfs-submit-1(693): WRITE block
213303152 on dm-3 (656 sectors) [83609.789232] btrfs-submit-1(693):
WRITE block 220967528 on dm-3 (656 sectors) [83609.789300]
btrfs-submit-1(693): WRITE block 221121680 on dm-3 (656 sectors)
[83609.789387] btrfs-submit-1(693): WRITE block 209254840 on dm-3 (648
sectors) [83609.789455] btrfs-submit-1(693): WRITE block 209273008 on
dm-3 (648 sectors) [83609.789520] btrfs-submit-1(693): WRITE block
209342320 on dm-3 (648 sectors) [83609.789581] btrfs-submit-1(693):
WRITE block 209609632 on dm-3 (640 sectors) [83609.789648]
btrfs-submit-1(693): WRITE block 209916672 on dm-3 (640 sectors)
[83609.789708] btrfs-submit-1(693): WRITE block 210032808 on dm-3 (640
sectors) [83609.789770] btrfs-submit-1(693): WRITE block 210859360 on
dm-3 (632 sectors) [83609.789831] btrfs-submit-1(693): WRITE block
211141472 on dm-3 (632 sectors) [83609.789889] btrfs-submit-1(693):
WRITE block 212197960 on dm-3 (632 sectors) [83609.789943]
btrfs-submit-1(693): WRITE block 209601952 on dm-3 (624 sectors)
[83609.789985] btrfs-submit-1(693): WRITE block 209981704 on dm-3 (624
sectors) [83609.790050] btrfs-submit-1(693): WRITE block 211000096 on
dm-3 (624 sectors) [83609.790097] btrfs-submit-1(693): WRITE block
211844216 on dm-3 (624 sectors) [83609.790159] btrfs-submit-1(693):
WRITE block 210001392 on dm-3 (616 sectors) [83609.790224]
btrfs-submit-1(693): WRITE block 211883752 on dm-3 (616 sectors)
[83609.790233] btrfs-submit-1(693): WRITE block 212241552 on dm-3 (112
sectors) [83609.790282] btrfs-submit-1(693): WRITE block 212241664 on
dm-3 (504 sectors) [83609.790367] btrfs-submit-1(693): WRITE block
209611968 on dm-3 (608 sectors) [83609.790413] btrfs-submit-1(693):
WRITE block 212364704 on dm-3 (608 sectors) [83609.790454]
btrfs-submit-1(693): WRITE block 212395176 on dm-3 (608 sectors)
[83609.790493] btrfs-submit-1(693): WRITE block 207705176 on dm-3 (600
sectors) [83609.790534] btrfs-submit-1(693): WRITE block 209170256 on
dm-3 (600 sectors) [83609.790574] btrfs-submit-1(693): WRITE block
210514040 on dm-3 (600 sectors) [83609.790623] btrfs-submit-1(693):
WRITE block 210817032 on dm-3 (600 sectors) [83609.790663]
btrfs-submit-1(693): WRITE block 196747144 on dm-3 (592 sectors)
[83609.790703] btrfs-submit-1(693): WRITE block 197550360 on dm-3 (592
sectors) [83609.790751] btrfs-submit-1(693): WRITE block 199131832 on
dm-3 (592 sectors) [83609.790802] btrfs-submit-1(693): WRITE block
139538304 on dm-3 (584 sectors) [83609.790859] btrfs-submit-1(693):
WRITE block 139985408 on dm-3 (584 sectors) [83609.790917]
btrfs-submit-1(693): WRITE block 139997288 on dm-3 (584 sectors)
[83609.790956] btrfs-submit-1(693): WRITE block 141002160 on dm-3 (584
sectors) [83609.790999] btrfs-submit-1(693): WRITE block 94974784 on
dm-3 (576 sectors) [83609.791053] btrfs-submit-1(693): WRITE block
95005296 on dm-3 (576 sectors) [83609.791116] btrfs-submit-1(693):
WRITE block 95308560 on dm-3 (576 sectors) [83609.791188]
btrfs-submit-1(693): WRITE block 89186376 on dm-3 (568 sectors)
[83609.791252] btrfs-submit-1(693): WRITE block 89535056 on dm-3 (568
sectors) [83609.791310] btrfs-submit-1(693): WRITE block 92231480 on
dm-3 (568 sectors) [83609.791384] btrfs-submit-1(693): WRITE block
94111640 on dm-3 (568 sectors) [83609.791438] btrfs-submit-1(693):
WRITE block 66957296 on dm-3 (560 sectors) [83609.791483]
btrfs-submit-1(693): WRITE block 68589872 on dm-3 (560 sectors)
[83609.791528] btrfs-submit-1(693): WRITE block 72539056 on dm-3 (560
sectors) [83609.791631] btrfs-submit-1(693): WRITE block 361598360 on
dm-3 (1024 sectors) [83609.791639] btrfs-submit-1(693): WRITE block
361599384 on dm-3 (88 sectors) [83609.791692] btrfs-submit-1(693):
WRITE block 358276792 on dm-3 (832 sectors) [83609.791712]
btrfs-submit-1(693): WRITE block 358277624 on dm-3 (272 sectors)
[83609.791792] btrfs-submit-1(693): WRITE block 356761432 on dm-3
(1024 sectors) [83609.791799] btrfs-submit-1(693): WRITE block
356762456 on dm-3 (72 sectors) [83609.791865] btrfs-submit-1(693):
WRITE block 346717072 on dm-3 (1024 sectors) [83609.791871]
btrfs-submit-1(693): WRITE block 346718096 on dm-3 (64 sectors)
[83609.791945] btrfs-submit-1(693): WRITE block 329314256 on dm-3
(1024 sectors) [83609.791950] btrfs-submit-1(693): WRITE block
329315280 on dm-3 (56 sectors) [83609.792024] btrfs-submit-1(693):
WRITE block 329519576 on dm-3 (1024 sectors) [83609.792029]
btrfs-submit-1(693): WRITE block 329520600 on dm-3 (48 sectors)
[83609.792109] btrfs-submit-1(693): WRITE block 332254520 on dm-3
(1024 sectors) [83609.792114] btrfs-submit-1(693): WRITE block
332255544 on dm-3 (40 sectors) [83609.792209] btrfs-submit-1(693):
WRITE block 324987472 on dm-3 (1024 sectors) [83609.792212]
btrfs-submit-1(693): WRITE block 324988496 on dm-3 (32 sectors)
[83609.792315] btrfs-submit-1(693): WRITE block 323007400 on dm-3
(1024 sectors) [83609.792320] btrfs-submit-1(693): WRITE block
323008424 on dm-3 (24 sectors) [83609.792421] btrfs-submit-1(693):
WRITE block 299058832 on dm-3 (1024 sectors) [83609.792424]
btrfs-submit-1(693): WRITE block 299059856 on dm-3 (16 sectors)
[83609.792513] btrfs-submit-1(693): WRITE block 294291832 on dm-3
(1024 sectors) [83609.792516] btrfs-submit-1(693): WRITE block
294292856 on dm-3 (8 sectors) [83609.792580] btrfs-submit-1(693):
WRITE block 261625480 on dm-3 (1024 sectors) [83609.792655]
btrfs-submit-1(693): WRITE block 261854672 on dm-3 (1016 sectors)
[83609.792726] btrfs-submit-1(693): WRITE block 283307984 on dm-3
(1008 sectors) [83609.792797] btrfs-submit-1(693): WRITE block
282760344 on dm-3 (1000 sectors) [83609.792864] btrfs-submit-1(693):
WRITE block 261292960 on dm-3 (992 sectors) [83609.792932]
btrfs-submit-1(693): WRITE block 282915688 on dm-3 (984 sectors)
[83609.792972] btrfs-submit-1(693): WRITE block 261631920 on dm-3 (592
sectors) [83609.792999] btrfs-submit-1(693): WRITE block 261632512 on
dm-3 (384 sectors) [83609.793068] btrfs-submit-1(693): WRITE block
261855696 on dm-3 (968 sectors) [83609.793129] btrfs-submit-1(693):
WRITE block 283200008 on dm-3 (960 sectors) [83609.793219]
btrfs-submit-1(693): WRITE block 282934216 on dm-3 (952 sectors)
[83609.793316] btrfs-submit-1(693): WRITE block 261516120 on dm-3 (944
sectors) [83609.793401] btrfs-submit-1(693): WRITE block 261825272 on
dm-3 (936 sectors) [83609.793461] btrfs-submit-1(693): WRITE block
283711744 on dm-3 (928 sectors) [83609.793522] btrfs-submit-1(693):
WRITE block 284053784 on dm-3 (928 sectors) [83609.793582]
btrfs-submit-1(693): WRITE block 284087824 on dm-3 (920 sectors)
[83609.793645] btrfs-submit-1(693): WRITE block 283896944 on dm-3 (912
sectors) [83609.793706] btrfs-submit-1(693): WRITE block 261203920 on
dm-3 (904 sectors) [83609.793765] btrfs-submit-1(693): WRITE block
283228264 on dm-3 (896 sectors) [83609.793823] btrfs-submit-1(693):
WRITE block 283235128 on dm-3 (888 sectors) [83609.793880]
btrfs-submit-1(693): WRITE block 283214032 on dm-3 (880 sectors)
[83609.793935] btrfs-submit-1(693): WRITE block 283817752 on dm-3 (872
sectors) [83609.793990] btrfs-submit-1(693): WRITE block 283820232 on
dm-3 (864 sectors) [83609.794045] btrfs-submit-1(693): WRITE block
284096736 on dm-3 (864 sectors) [83609.794105] btrfs-submit-1(693):
WRITE block 283752904 on dm-3 (856 sectors) [83609.794143]
btrfs-submit-1(693): WRITE block 283196200 on dm-3 (608 sectors)
[83609.794160] btrfs-submit-1(693): WRITE block 283196808 on dm-3 (240
sectors) [83609.794236] btrfs-submit-1(693): WRITE block 255729560 on
dm-3 (840 sectors) [83609.794317] btrfs-submit-1(693): WRITE block
257311304 on dm-3 (832 sectors) [83609.794396] btrfs-submit-1(693):
WRITE block 254780104 on dm-3 (824 sectors) [83609.794459]
btrfs-submit-1(693): WRITE block 260878504 on dm-3 (824 sectors)
[83609.794511] btrfs-submit-1(693): WRITE block 246921000 on dm-3 (816
sectors) [83609.794564] btrfs-submit-1(693): WRITE block 246239848 on
dm-3 (808 sectors) [83609.794616] btrfs-submit-1(693): WRITE block
247011416 on dm-3 (800 sectors) [83609.794669] btrfs-submit-1(693):
WRITE block 248999952 on dm-3 (800 sectors) [83609.794720]
btrfs-submit-1(693): WRITE block 249731832 on dm-3 (792 sectors)
[83609.794770] btrfs-submit-1(693): WRITE block 248926960 on dm-3 (784
sectors) [83609.794820] btrfs-submit-1(693): WRITE block 245479592 on
dm-3 (776 sectors) [83609.794870] btrfs-submit-1(693): WRITE block
247307080 on dm-3 (768 sectors) [83609.794919] btrfs-submit-1(693):
WRITE block 250065752 on dm-3 (768 sectors) [83609.794969]
btrfs-submit-1(693): WRITE block 247002760 on dm-3 (760 sectors)
[83609.795017] btrfs-submit-1(693): WRITE block 244893248 on dm-3 (752
sectors) [83609.795089] btrfs-submit-1(693): WRITE block 245217680 on
dm-3 (744 sectors) [83609.795120] btrfs-submit-1(693): WRITE block
246965056 on dm-3 (744 sectors) [83609.795196] btrfs-submit-1(693):
WRITE block 247315304 on dm-3 (736 sectors) [83609.795267]
btrfs-submit-1(693): WRITE block 244491848 on dm-3 (728 sectors)
[83609.795343] btrfs-submit-1(693): WRITE block 248445672 on dm-3 (728
sectors) [83609.795387] btrfs-submit-1(693): WRITE block 246944992 on
dm-3 (600 sectors) [83609.795397] btrfs-submit-1(693): WRITE block
246945592 on dm-3 (120 sectors) [83609.795459] btrfs-submit-1(693):
WRITE block 244842816 on dm-3 (712 sectors) [83609.795505]
btrfs-submit-1(693): WRITE block 232657344 on dm-3 (704 sectors)
[83609.795560] btrfs-submit-1(693): WRITE block 236715992 on dm-3 (704
sectors) [83609.795606] btrfs-submit-1(693): WRITE block 232380128 on
dm-3 (696 sectors) [83609.795656] btrfs-submit-1(693): WRITE block
232870320 on dm-3 (688 sectors) [83609.795705] btrfs-submit-1(693):
WRITE block 233027744 on dm-3 (688 sectors) [83609.795753]
btrfs-submit-1(693): WRITE block 233417744 on dm-3 (680 sectors)
[83609.795797] btrfs-submit-1(693): WRITE block 225202568 on dm-3 (672
sectors) [83609.795841] btrfs-submit-1(693): WRITE block 230475976 on
dm-3 (672 sectors) [83609.795886] btrfs-submit-1(693): WRITE block
230563168 on dm-3 (664 sectors) [83609.795930] btrfs-submit-1(693):
WRITE block 221134104 on dm-3 (656 sectors) [83609.795973]
btrfs-submit-1(693): WRITE block 229989032 on dm-3 (656 sectors)
[83609.796015] btrfs-submit-1(693): WRITE block 212861680 on dm-3 (648
sectors) [83609.796081] btrfs-submit-1(693): WRITE block 213388440 on
dm-3 (648 sectors) [83609.796106] btrfs-submit-1(693): WRITE block
212859720 on dm-3 (640 sectors) [83609.796146] btrfs-submit-1(693):
WRITE block 213188168 on dm-3 (632 sectors) [83609.796203]
btrfs-submit-1(693): WRITE block 213424376 on dm-3 (632 sectors)
[83609.796265] btrfs-submit-1(693): WRITE block 212513360 on dm-3 (624
sectors) [83609.796322] btrfs-submit-1(693): WRITE block 212536376 on
dm-3 (616 sectors) [83609.796381] btrfs-submit-1(693): WRITE block
212921632 on dm-3 (616 sectors) [83609.796438] btrfs-submit-1(693):
WRITE block 213167656 on dm-3 (608 sectors) [83609.796499]
btrfs-submit-1(693): WRITE block 213527992 on dm-3 (608 sectors)
[83609.796539] btrfs-submit-1(693): WRITE block 212337248 on dm-3 (600
sectors) [83609.796581] btrfs-submit-1(693): WRITE block 200281640 on
dm-3 (592 sectors) [83609.796626] btrfs-submit-1(693): WRITE block
205931992 on dm-3 (592 sectors) [83609.796634] btrfs-submit-1(693):
WRITE block 143283192 on dm-3 (96 sectors) [83609.796667]
btrfs-submit-1(693): WRITE block 143283288 on dm-3 (488 sectors)
[83609.796709] btrfs-submit-1(693): WRITE block 143320424 on dm-3 (584
sectors) [83609.796748] btrfs-submit-1(693): WRITE block 96148048 on
dm-3 (576 sectors) [83609.796789] btrfs-submit-1(693): WRITE block
99471864 on dm-3 (576 sectors) [83609.796828] btrfs-submit-1(693):
WRITE block 94966448 on dm-3 (568 sectors) [83609.796866]
btrfs-submit-1(693): WRITE block 72542992 on dm-3 (560 sectors)
[83609.796903] btrfs-submit-1(693): WRITE block 76475904 on dm-3 (560
sectors) [83609.796940] btrfs-submit-1(693): WRITE block 38678200 on
dm-3 (552 sectors) [83609.796976] btrfs-submit-1(693): WRITE block
41250976 on dm-3 (552 sectors) [83609.797012] btrfs-submit-1(693):
WRITE block 41934160 on dm-3 (544 sectors) [83609.797105]
btrfs-submit-1(693): WRITE block 348023856 on dm-3 (1024 sectors)
[83609.797113] btrfs-submit-1(693): WRITE block 348024880 on dm-3 (64
sectors) [83609.797196] btrfs-submit-1(693): WRITE block 335091864 on
dm-3 (1024 sectors) [83609.797200] btrfs-submit-1(693): WRITE block
335092888 on dm-3 (48 sectors) [83609.797309] btrfs-submit-1(693):
WRITE block 329725128 on dm-3 (1024 sectors) [83609.797313]
btrfs-submit-1(693): WRITE block 329726152 on dm-3 (32 sectors)
[83609.797413] btrfs-submit-1(693): WRITE block 301741856 on dm-3
(1024 sectors) [83609.797417] btrfs-submit-1(693): WRITE block
301742880 on dm-3 (16 sectors) [83609.797504] btrfs-submit-1(693):
WRITE block 292443032 on dm-3 (1024 sectors) [83609.797575]
btrfs-submit-1(693): WRITE block 284647976 on dm-3 (1008 sectors)
[83609.797645] btrfs-submit-1(693): WRITE block 284672256 on dm-3 (992
sectors) [83609.797713] btrfs-submit-1(693): WRITE block 286858248 on
dm-3 (976 sectors) [83609.797776] btrfs-submit-1(693): WRITE block
293660104 on dm-3 (960 sectors) [83609.797842] btrfs-submit-1(693):
WRITE block 294320464 on dm-3 (944 sectors) [83609.797891]
btrfs-submit-1(693): WRITE block 293465400 on dm-3 (744 sectors)
[83609.797905] btrfs-submit-1(693): WRITE block 293466144 on dm-3 (184
sectors) [83609.797966] btrfs-submit-1(693): WRITE block 284753000 on
dm-3 (912 sectors) [83609.798030] btrfs-submit-1(693): WRITE block
293900840 on dm-3 (904 sectors) [83609.798097] btrfs-submit-1(693):
WRITE block 293527144 on dm-3 (888 sectors) [83609.798171]
btrfs-submit-1(693): WRITE block 286831760 on dm-3 (872 sectors)
[83609.798253] btrfs-submit-1(693): WRITE block 284539512 on dm-3 (856
sectors) [83609.798333] btrfs-submit-1(693): WRITE block 292352360 on
dm-3 (848 sectors) [83609.798402] btrfs-submit-1(693): WRITE block
261727976 on dm-3 (832 sectors) [83609.798455] btrfs-submit-1(693):
WRITE block 256672496 on dm-3 (816 sectors) [83609.798509]
btrfs-submit-1(693): WRITE block 252596448 on dm-3 (808 sectors)
[83609.798559] btrfs-submit-1(693): WRITE block 253207192 on dm-3 (792
sectors) [83609.798610] btrfs-submit-1(693): WRITE block 251678400 on
dm-3 (784 sectors) [83609.798662] btrfs-submit-1(693): WRITE block
252026880 on dm-3 (768 sectors) [83609.798712] btrfs-submit-1(693):
WRITE block 251717032 on dm-3 (760 sectors) [83609.798760]
btrfs-submit-1(693): WRITE block 252550312 on dm-3 (744 sectors)
[83609.798808] btrfs-submit-1(693): WRITE block 252574960 on dm-3 (736
sectors) [83609.798853] btrfs-submit-1(693): WRITE block 247387024 on
dm-3 (720 sectors) [83609.798898] btrfs-submit-1(693): WRITE block
248932984 on dm-3 (712 sectors) [83609.798944] btrfs-submit-1(693):
WRITE block 239455264 on dm-3 (704 sectors) [83609.798988]
btrfs-submit-1(693): WRITE block 234266224 on dm-3 (688 sectors)
[83609.799032] btrfs-submit-1(693): WRITE block 234283720 on dm-3 (680
sectors) [83609.799101] btrfs-submit-1(693): WRITE block 230797624 on
dm-3 (456 sectors) [83609.799115] btrfs-submit-1(693): WRITE block
230798080 on dm-3 (208 sectors) [83609.799127] btrfs-submit-1(693):
WRITE block 230955488 on dm-3 (656 sectors) [83609.799168]
btrfs-submit-1(693): WRITE block 219882728 on dm-3 (648 sectors)
[83609.799214] btrfs-submit-1(693): WRITE block 213748512 on dm-3 (640
sectors) [83609.799273] btrfs-submit-1(693): WRITE block 214514368 on
dm-3 (624 sectors) [83609.799332] btrfs-submit-1(693): WRITE block
215266576 on dm-3 (616 sectors) [83609.799396] btrfs-submit-1(693):
WRITE block 216075320 on dm-3 (608 sectors) [83609.799455]
btrfs-submit-1(693): WRITE block 212385568 on dm-3 (600 sectors)
[83609.799504] btrfs-submit-1(693): WRITE block 206894336 on dm-3 (592
sectors) [83609.799542] btrfs-submit-1(693): WRITE block 99812608 on
dm-3 (576 sectors) [83609.799579] btrfs-submit-1(693): WRITE block
94979104 on dm-3 (568 sectors) [83609.799616] btrfs-submit-1(693):
WRITE block 79352864 on dm-3 (560 sectors) [83609.799653]
btrfs-submit-1(693): WRITE block 47646336 on dm-3 (552 sectors)
[83609.799691] btrfs-submit-1(693): WRITE block 42925424 on dm-3 (544
sectors) [83609.799788] btrfs-submit-1(693): WRITE block 338987264 on
dm-3 (1024 sectors) [83609.799794] btrfs-submit-1(693): WRITE block
338988288 on dm-3 (48 sectors) [83609.799861] btrfs-submit-1(693):
WRITE block 301929936 on dm-3 (1024 sectors) [83609.799864]
btrfs-submit-1(693): WRITE block 301930960 on dm-3 (16 sectors)
[83609.799930] btrfs-submit-1(693): WRITE block 294746856 on dm-3
(1008 sectors) [83609.799993] btrfs-submit-1(693): WRITE block
294748224 on dm-3 (976 sectors) [83609.800091] btrfs-submit-1(693):
WRITE block 294756000 on dm-3 (944 sectors) [83609.800117]
btrfs-submit-1(693): WRITE block 294095136 on dm-3 (920 sectors)
[83609.800191] btrfs-submit-1(693): WRITE block 294821960 on dm-3 (888
sectors) [83609.800277] btrfs-submit-1(693): WRITE block 294859968 on
dm-3 (864 sectors) [83609.800348] btrfs-submit-1(693): WRITE block
283254160 on dm-3 (760 sectors) [83609.800355] btrfs-submit-1(693):
WRITE block 283254920 on dm-3 (72 sectors) [83609.800431]
btrfs-submit-1(693): WRITE block 259775440 on dm-3 (808 sectors)
[83609.800482] btrfs-submit-1(693): WRITE block 255562736 on dm-3 (784
sectors) [83609.800534] btrfs-submit-1(693): WRITE block 254482224 on
dm-3 (760 sectors) [83609.800583] btrfs-submit-1(693): WRITE block
253835368 on dm-3 (736 sectors) [83609.800632] btrfs-submit-1(693):
WRITE block 254535424 on dm-3 (712 sectors) [83609.800677]
btrfs-submit-1(693): WRITE block 235866216 on dm-3 (688 sectors)
[83609.800723] btrfs-submit-1(693): WRITE block 232206560 on dm-3 (672
sectors) [83609.800765] btrfs-submit-1(693): WRITE block 219958640 on
dm-3 (648 sectors) [83609.800808] btrfs-submit-1(693): WRITE block
217174224 on dm-3 (624 sectors) [83609.800849] btrfs-submit-1(693):
WRITE block 217383256 on dm-3 (608 sectors) [83609.800889]
btrfs-submit-1(693): WRITE block 208739760 on dm-3 (592 sectors)
[83609.800928] btrfs-submit-1(693): WRITE block 94983624 on dm-3 (568
sectors) [83609.800966] btrfs-submit-1(693): WRITE block 64859968 on
dm-3 (552 sectors) [83609.801042] btrfs-submit-1(693): WRITE block
341586008 on dm-3 (1024 sectors) [83609.801046] btrfs-submit-1(693):
WRITE block 341587032 on dm-3 (48 sectors) [83609.801117]
btrfs-submit-1(693): WRITE block 295363024 on dm-3 (1008 sectors)
[83609.801198] btrfs-submit-1(693): WRITE block 294897376 on dm-3 (944
sectors) [83609.801285] btrfs-submit-1(693): WRITE block 294976680 on
dm-3 (888 sectors) [83609.801366] btrfs-submit-1(693): WRITE block
283744400 on dm-3 (832 sectors) [83609.801440] btrfs-submit-1(693):
WRITE block 257890432 on dm-3 (776 sectors) [83609.801493]
btrfs-submit-1(693): WRITE block 254778824 on dm-3 (728 sectors)
[83609.801539] btrfs-submit-1(693): WRITE block 237227488 on dm-3 (680
sectors) [83609.801581] btrfs-submit-1(693): WRITE block 219236712 on
dm-3 (640 sectors) [83609.801587] btrfs-submit-1(693): WRITE block
212400024 on dm-3 (72 sectors) [83609.801624] btrfs-submit-1(693):
WRITE block 212400096 on dm-3 (528 sectors) [83609.801661]
btrfs-submit-1(693): WRITE block 79764944 on dm-3 (560 sectors)
[83609.801748] btrfs-submit-1(693): WRITE block 336699376 on dm-3
(1024 sectors) [83609.801752] btrfs-submit-1(693): WRITE block
336700400 on dm-3 (40 sectors) [83609.801816] btrfs-submit-1(693):
WRITE block 295558632 on dm-3 (928 sectors) [83609.801870]
btrfs-submit-1(693): WRITE block 260561336 on dm-3 (816 sectors)
[83609.801917] btrfs-submit-1(693): WRITE block 254989736 on dm-3 (712
sectors) [83609.801959] btrfs-submit-1(693): WRITE block 219238688 on
dm-3 (624 sectors) [83609.801995] btrfs-submit-1(693): WRITE block
43066848 on dm-3 (544 sectors) [83609.802102] btrfs-submit-1(693):
WRITE block 296496136 on dm-3 (952 sectors) [83609.802154]
btrfs-submit-1(693): WRITE block 255497976 on dm-3 (720 sectors)
[83609.802280] btrfs-submit-1(693): WRITE block 353656584 on dm-3
(1024 sectors) [83609.802285] btrfs-submit-1(693): WRITE block
353657608 on dm-3 (56 sectors) [83609.802398] btrfs-submit-1(693):
WRITE block 356546360 on dm-3 (1024 sectors) [83610.041845]
emacs(4757): dirtied inode 1183665 (userlock.elc) on dm-2
[83610.042337] btrfs-endio-wri(21111): READ block 69347272 on dm-3 (8
sectors) [83610.042519] btrfs-endio-wri(21081): READ block 2039352 on
dm-3 (8 sectors) [83610.042670] btrfs-endio-wri(20802): READ block
69347400 on dm-3 (8 sectors) [83610.043181] btrfs-endio-wri(23271):
READ block 69348384 on dm-3 (8 sectors) [83610.043454]
btrfs-endio-wri(21082): READ block 69423112 on dm-3 (8 sectors)
[83610.045848] btrfs-endio-wri(21084): READ block 69308472 on dm-3 (8
sectors) [83610.119675] btrfs-transacti(726): WRITE block 128 on dm-3
(8 sectors) [83610.119681] btrfs-transacti(726): WRITE block 131072 on
dm-3 (8 sectors)

On an earlier block_dump run, I had tons of StreamTrans READ requests.

/proc/meminfo's Dirty field was bouncing around between 900MB and 1.6GB.

For whatever reason, my btrfs performance issues are almost never
triggered by anything but emacs :-/

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
