Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 3ABFC6B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 03:08:24 -0400 (EDT)
Received: by ggm4 with SMTP id 4so3429776ggm.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 00:08:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ8eaTw_g6s0SO7uePnksb_g64TN2R5R69W+vk-8sYHrv3nCGw@mail.gmail.com>
References: <CAJ8eaTw_g6s0SO7uePnksb_g64TN2R5R69W+vk-8sYHrv3nCGw@mail.gmail.com>
Date: Fri, 27 Jul 2012 12:38:22 +0530
Message-ID: <CAJ8eaTwOtz=5bqZNveAhzbFenV7sYF0vceZ3aZHffP8bgJVkiw@mail.gmail.com>
Subject: Re: Issue with block I/O cgroup in case of threads
From: naveen yadav <yad.naveen@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, khlebnikov@openvz.org, david@fromorbit.com, akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We are using 3.0.33 kernel and verification is done on ARM cortex a9.


On Fri, Jul 27, 2012 at 12:33 PM, naveen yadav <yad.naveen@gmail.com> wrote:
> Hi All,
>
>
> I am testing the cgroup block IO attributes in multiple threads scenario.
> I tried testing Throttling policy (max read/write bytes per second per device)
>  that can be set using the following attribute-
> "blkio.throttle.write_bps_device"
> "blkio.throttle.read_bps_device"
> but  I am not getting appropriate bandwidth readings, in case of
> process and threads.
>
> The following is my kernel configuration-
> # CONFIG_RCU_BOOST is not set
> # CONFIG_IKCONFIG is not set
> CONFIG_LOG_BUF_SHIFT=17
> CONFIG_CGROUPS=y
> # CONFIG_CGROUP_DEBUG is not set
> # CONFIG_CGROUP_FREEZER is not set
> CONFIG_CGROUP_DEVICE=y
> # CONFIG_CPUSETS is not set
> # CONFIG_CGROUP_CPUACCT is not set
> CONFIG_RESOURCE_COUNTERS=y
> CONFIG_CGROUP_MEM_RES_CTLR=y
> CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
> CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED=y
> # CONFIG_CGROUP_PERF is not set
> CONFIG_CGROUP_SCHED=y
> CONFIG_FAIR_GROUP_SCHED=y
> CONFIG_RT_GROUP_SCHED=y
> CONFIG_BLK_CGROUP=y
> CONFIG_DEBUG_BLK_CGROUP=y
> # CONFIG_NAMESPACES is not set
> CONFIG_BLK_DEV_THROTTLING=y
> CONFIG_CFQ_GROUP_IOSCHED=y
>
> Below is the procedure that I followed for testing-
> first of all I mounted the cgroup blkio on /mnt
> $mount -t cgroup -o blkio none /mnt
> $mount | grep "cgroup"
> ==> output
> none on /sys/fs/cgroup type cgroup (rw,relatime,cpu)
> none on /mnt type cgroup (rw,relatime,blkio)
>
> The default readings were taken through dd command
> $dd if=linux.3.0.20.tgz of=/dev/null bs=4096 count=51200
> 28419+1 records in
> 28419+1 records out
> 116405611 bytes (111.0MB) copied, 6.041795 seconds, 18.4MB/s
> $dd if=/dev/zero of=test1 bs=4096 count=51200
> 51200+0 records in
> 51200+0 records out
> 209715200 bytes (200.0MB) copied, 31.203680 seconds, 6.4MB/s
>
> Then I made two groups in /mnt named g1 and g2 and set the bandwidth -
> $echo "8:0 2097152" > /mnt/g1/blkio.throttle.read_bps_device            //2MB
> $echo "8:0 16777216" > /mnt/g2/blkio.throttle.read_bps_device           //16MB
> $echo "8:0 1048576" > /mnt/g1/blkio.throttle.write_bps_device           //1MB
> $echo "8:0 5242880" > /mnt/g2/blkio.throttle.write_bps_device           //5MB
>
> Test program -
> ////////////////////////////////////////////////////////////////////////////////////
> #define MAX_NAME_LEN    16
> #define NO_THREADS              2
>
> volatile char flag=0;
> struct sigaction sigact;
> static char count=0;
>
> void *threadFunc(void *arg)
> {
>                 char cmd[100];
>                 sprintf(cmd,"dd if=/dev/zero of=ThreadTest%d bs=4096 count=51200",++count);
>                 while(flag != 2);
>                 system("echo 3 > /proc/sys/vm/drop_caches");
>
>                 system("dd if=Linux.3.0.20.tgz of=/dev/null bs=4096 count=51200");
>                 system("echo 3 > /proc/sys/vm/drop_caches");
>                 system(cmd);
>         while(1);
>                 return NULL;
> }
>
> static void signal_handler(int sig)     {
>         printf("Caught signal SIGUSR1 : %d\n",sig);
>         flag = 1;
> }
>
> void init_signals(void) {
>         sigact.sa_handler = signal_handler;
>         sigemptyset(&sigact.sa_mask);
>         sigact.sa_flags = 0;
>         sigaction(SIGUSR1, &sigact, (struct sigaction *)NULL);
> }
>
> int main(int argc, char *argv[])
> {
>         pid_t pid;
>                 pthread_t pth[2];
>         struct sched_param mysched;
>         char name[MAX_NAME_LEN + 1];
>         int i;
>                 int j;
>
>                 init_signals();
>         mysched.sched_priority = 19;
>
>         for (i=0; i<3; ++i) {
>                 pid = fork();
>                 if (pid == 0) {
>                         sprintf(name, "%d",i);
>                         prctl(PR_SET_NAME, (unsigned long)&name);
>
>                         if (argc==2 && !strcmp(argv[1], "FIFO")) {
>                                 sched_setscheduler(0, SCHED_FIFO, &mysched);
>                         } else if (argc==2 && !strcmp(argv[1], "RR")) {
>                                 sched_setscheduler(0, SCHED_RR, &mysched);
>                         }
>                         printf("\nPID=%d, Sched Policy=%d\n",
> getpid(),sched_getscheduler );
>
>                                                 sleep(30);
>                                                 printf("Starting Thread Creation\n");
>
>                                                 for(j=0;j<NO_THREADS;j++)       {
>                                                         pthread_create(&pth[j],NULL,threadFunc,NULL);
>                                                 }
>
>                                                 while(!flag);
>                                                 printf("InProcess\n");
>                                                 system("echo 3 > /proc/sys/vm/drop_caches");
>                                                 system("dd if=Linux.3.0.20.tgz of=/dev/null bs=4096 count=51200");
>                                                 system("echo 3 > /proc/sys/vm/drop_caches");
>                                                 system("dd if=/dtv/usb/sda1/temp of=ProcessTest bs=4096 count=51200");
>                                                 flag++;
>
>                                                 for(j=0;j<NO_THREADS;j++)       {
>                                                         pthread_join(pth[j], NULL);
>                                                 }
>                 }
>         }
>         return 0;
> }
> ////////////////////////////////////////////////////////////////////////////////////////////////////////
>
> ProcedureProcedure to run:
>
> linux#> ./cgroup_thread_test_arm_blk
> cgroup_thread_test_arm_blk   cgroup_thread_test_arm_blk3
> linux#> ./cgroup_thread_test_arm_blk
>
> PID=130, Sched Policy=0
> linux#>
> PID=132, Sched Policy=0
>
> PID=131, Sched Policy=0
>
> linux#> echo 130  > /mnt/g1/tasks
> linux#> echo 131  > /mnt/g2/tasks
> linux#> Starting Thread Creation
> Starting Thread Creation
> Starting Thread Creation
>
> linux#>
> linux#> kill -SIGUSR1 130
> linux#> Caught signal SIGUSR1 : 10
> InProcess
> 28419+1 records in
> 28419+1 records out
> 116405611 bytes (111.0MB) copied, 56.019700 seconds, 2.0MB/s
> 51200+0 records in
> 51200+0 records out
> 209715200 bytes (200.0MB) copied, 30.881699 seconds, 6.5MB/s
> 28419+1 records in
> 28419+1 records out
> 116405611 bytes (111.0MB) copied, 28419+1 records in
> 28419+1 records out
> 116405611 bytes (111.0MB) copied, 63.842881 seconds, 1.7MB/s
> 63.844210 seconds, 1.7MB/s
> 51200+0 records in
> 51200+0 records out
> 209715200 bytes (200.0MB) copied, 51200+0 records in
> 51200+0 records out
> 209715200 bytes (200.0MB) copied, 62.031691 seconds, 3.2MB/s
> 62.029856 seconds, 3.2MB/s
>
> linux#> kill -SIGUSR1 131
> linux#> Caught signal SIGUSR1 : 10
> InProcess
> 28419+1 records in
> 28419+1 records out
> 116405611 bytes (111.0MB) copied, 11.231604 seconds, 9.9MB/s
> 51200+0 records in
> 51200+0 records out
> 209715200 bytes (200.0MB) copied, 38.505295 seconds, 5.2MB/s
> 28419+1 records in
> 28419+1 records out
> 116405611 bytes (111.0MB) copied, 28419+1 records in
> 28419+1 records out
> 116405611 bytes (111.0MB) copied, 28.580193 seconds, 3.9MB/s
> 28.578926 seconds, 3.9MB/s
> 51200+0 records in
> 51200+0 records out
> 209715200 bytes (200.0MB) copied, 267.614328 seconds, 765.3KB/s
> 51200+0 records in
> 51200+0 records out
> 209715200 bytes (200.0MB) copied, 269.800526 seconds, 759.1KB/s
>
> The limits assigned to the cgroups are not followed by process.
>
>
>
> Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
