Received: from mail.ccr.net (ccr@alogconduit1ai.ccr.net [208.130.159.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA02543
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 08:34:10 -0500
Subject: Unoverload mmput functionality.
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 18 Jan 1999 07:33:52 -0600
Message-ID: <m1k8yk3dtr.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Enclosed are 2 patches.
The first unoverloads the job of mmput.  

The problem is currently there are times that mmput is legitamently
called, (by procfs, or when we can't allocate a new page table).
Where we don't want to clear the segment registers, or wake up
a sleeping vfork.

So I have broken mmput into two functions
mmput & mm_release.  mm_release takes care of the chore
of detaching a mm_struct from the current task, and
mmput manages the mm_struct as it does now.


The second patch moves the vfork semaphore into do_fork,
so we can use clone(CLONE_VFORK | CLONE_VM | CLONE_SIGCHLD, ...)
to implement vfork.

Both patches are against 2.2.0-pre7 but they both apply
cleanly to pre-8.

begin 644 linux-2.2.0-pre7.eb1.1.diff.gz
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
43^_BJS9;I1MU^>9_9/>1@7$D``!@
`
end
begin 644 linux-2.2.0-pre7.eb1.2.diff.gz
M'XL("+4LHS8"`VQI;G5X+3(N,BXP+7!R93<N96(Q+C(N9&EF9@"M5EMSVD84
M?I9^Q?$+14@+NIB+Y&G&K4W:)`9FBIM)GS1K:0$5L=+H8IS)Y;?WK+3$X&)L
MF##`+M+YSDW?^98PFLV`E./L$\01+Q](-.=)QL@LBEDN+]EMNVV2-&/]-KNS
MVE:'9L&B0^-T03M+EG$6=](L"5B>MX/]$/L01"6$G!!)F=("WE,.5@]LQSMW
M/,L"RW5=5=?U$])01@FO_0W`M#RSC^_:W^4E$+MG&;8)NEBM+EQ>JO!%!26:
M0?.LS%,-]PJN\"MD(:Y-[4(E2L:*,N,0)OXLR9;-($XX\V<QG>?0@.]7-Y/Q
MT/_X=O+7!P,08T`S+[(R*"`M_(RA44O#2^N\H,%2MS1TJ1]P^5H?\$T%%2)>
M0-4'_[YR)%'Y.BJ"A5^90PLD4)/%(B981'$H:ML`V(JF"V2,V&'UH[]OAY_\
MF\G5A^$UQD+#H,PRQ@ORI@KDUV8-7/"V4KG#WYMZMGH"7T'^&N%V^NZ/JS]O
MKHU->PW1<.7%8@DF()Y1'><-F!I>4,)DS9LB!=$.="2;*FO#!H4G3T7D#'H;
M:F'5V>?V]"`7]]B_.`][,,JTE.0UP;:\<]LS!Z\;AGW.=B?!<3W3?9R$;M<U
M^J#7BY@#I8TDG,/TG]'ODQM__-MHV,P_Y_B@>2CZI3UKP2,?EX#&L:8H'61;
MD3&ZRBUH=8[%V`)#GL%4Q--@ZX5`RS4%1G\YSGZ@X$VGA5\X)N/)[?#L#&X7
M48Y,9CG_I8`%O6=0)'#'@#U0Y"B!-8-_R[R^]9,H]CK=W8LXBF9;JKLA6E^H
MKM5#KAU/M.=$UQEXCO5(M?X`1=<"7:R2:YRM:Y7%<6^SX.%B(\+5C4J&=TWR
M]$@EKN`&-`1<*,@W(2(T7V%M2SIGE7+^8-53`:I`*ODB9.=HM22'U9*<HI:R
M!UOUO*B(Y+%?,O_#Q\Z3AM7G"X[&20R7!!%1GB?UCM$A'N\8_I^Z&UD[0-U=
M#T_8>NYUG4>VGKL]HP>Z6-R:K(("/+N0.^SA/8WQ\9'A>#(:CL1UR8N"YOBL
MZWTK%0U_%6%T-#QTO&(`,0@H8DG@;\40_T[DV.#(B-Q[CBUR[SE=8U#G7J;-
MQ@_?JY7XT-279Z92<G2Y].ON5.ZJZ$E9>)B3\/QDQK:HJD&C`4W9#4%`#1"S
C>RAO"%=;5:7<T;`BGQ_$C/(2<XGF"\I#3_T/Q+BUA\0*``"C
`
end
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
