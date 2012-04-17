Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id BC53F6B004D
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 05:22:41 -0400 (EDT)
Received: by dakh32 with SMTP id h32so8652694dak.9
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 02:22:41 -0700 (PDT)
Content-Type: text/plain; charset=gbk; format=flowed; delsp=yes
Subject: bug for stack ?
Date: Tue, 17 Apr 2012 17:20:20 +0800
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: gaoqiang <gaoqiangscut@gmail.com>
Message-ID: <op.wcwj76p5n27o5l@gaoqiang-d1.corp.qihoo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>


memory allocated for process stack seems never to be freed by the kernel=
..


on a vmware machine with about 768m memory, run the following program.wh=
en
printing "run over", run another case of the following program. oom-kill=
er
trigered, which is not so reasonable.


#include <stdio.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <alloca.h>
void*stack=3DNULL;
const long water_mark=3D512*1024*1024;
void func()
{
	int p=3D0;
	if((long)stack-(long)&p> water_mark)
	{
		printf("hit\n");
	}
	else
	{
		func();
	}
	return;
}
int main()
{
	struct rlimit limit;
	limit.rlim_cur=3D1024*1024*1024*1.5;
	limit.rlim_max=3D1024*1024*1024*1.5;
	setrlimit(RLIMIT_STACK,&limit);
	int a=3D0;
	stack=3D&a;
	printf("run\n");
	//getchar();
	func();
	printf("run over\n");
	getchar();
	return 0;
}

-- =

=CA=B9=D3=C3 Opera =B8=EF=C3=FC=D0=D4=B5=C4=B5=E7=D7=D3=D3=CA=BC=FE=BF=CD=
=BB=A7=B3=CC=D0=F2: http://www.opera.com/mail/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
