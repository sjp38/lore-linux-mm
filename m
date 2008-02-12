Message-ID: <47B16AB7.1050100@bull.net>
Date: Tue, 12 Feb 2008 10:45:27 +0100
From: Nadia Derbey <Nadia.Derbey@bull.net>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] Do not recompute msgmni anymore if explicitely set
 by user
References: <20080211141646.948191000@bull.net>	<20080211141816.094061000@bull.net>	<20080211122408.5008902f.akpm@linux-foundation.org> <47B167AF.6010008@bull.net>
In-Reply-To: <47B167AF.6010008@bull.net>
Content-Type: multipart/mixed;
 boundary="------------030102020103080703060209"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia Derbey <Nadia.Derbey@bull.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cmm@us.ibm.com, matthltc@us.ibm.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030102020103080703060209
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nadia Derbey wrote:
> Andrew Morton wrote:
> 
>> On Mon, 11 Feb 2008 15:16:53 +0100
>> Nadia.Derbey@bull.net wrote:
>>
>>
>>> [PATCH 07/08]
>>>
>>> This patch makes msgmni not recomputed anymore upon ipc namespace 
>>> creation /
>>> removal or memory add/remove, as soon as it has been set from userland.
>>>
>>> As soon as msgmni is explicitely set via procfs or sysctl(), the 
>>> associated
>>> callback routine is unregistered from the ipc namespace notifier chain.
>>>
>>
>>
>> The patch series looks pretty good.
>>
>>
>>> ===================================================================
>>> --- linux-2.6.24-mm1.orig/ipc/ipc_sysctl.c    2008-02-08 
>>> 16:07:15.000000000 +0100
>>> +++ linux-2.6.24-mm1/ipc/ipc_sysctl.c    2008-02-08 
>>> 16:08:32.000000000 +0100
>>> @@ -35,6 +35,24 @@ static int proc_ipc_dointvec(ctl_table *
>>>     return proc_dointvec(&ipc_table, write, filp, buffer, lenp, ppos);
>>> }
>>>
>>> +static int proc_ipc_callback_dointvec(ctl_table *table, int write,
>>> +    struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
>>> +{
>>> +    size_t lenp_bef = *lenp;
>>> +    int rc;
>>> +
>>> +    rc = proc_ipc_dointvec(table, write, filp, buffer, lenp, ppos);
>>> +
>>> +    if (write && !rc && lenp_bef == *lenp)
>>> +        /*
>>> +         * Tunable has successfully been changed from userland:
>>> +         * disable its automatic recomputing.
>>> +         */
>>> +        unregister_ipcns_notifier(current->nsproxy->ipc_ns);
>>> +
>>> +    return rc;
>>> +}
>>
>>
>>
>> If you haven't done so, could you please check that it all builds cleanly
>> with CONFIG_PROCFS=n, and that all code which isn't needed if procfs is
>> disabled is not present in the final binary?
>>
>>
>>
>>
> 
> Andrew,
> 
> it builds fine, modulo some changes in ipv4 and ipv6 (see attached patch 
> - didn't find it in the hot fixes).
> 
> Regards,
> Nadia
> 
> 

Oops, forgot the patch. Thx Benjamin!




--------------030102020103080703060209
Content-Type: text/x-patch;
 name="ip_v4_v6_procfs.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ip_v4_v6_procfs.patch"

Fix header files to let IPV4 and IPV6 build if CONFIG_PROC_FS=n

Signed-off-by: Nadia Derbey <Nadia.Derbey@bull.net>

---
 include/net/ip_fib.h |   13 ++++++++++++-
 include/net/ipv6.h   |    6 +++---
 2 files changed, 15 insertions(+), 4 deletions(-)

Index: linux-2.6.24-mm1/include/net/ip_fib.h
===================================================================
--- linux-2.6.24-mm1.orig/include/net/ip_fib.h	2008-02-12 11:03:40.000000000 +0100
+++ linux-2.6.24-mm1/include/net/ip_fib.h	2008-02-12 11:09:40.000000000 +0100
@@ -266,6 +266,17 @@ static inline void fib_res_put(struct fi
 #ifdef CONFIG_PROC_FS
 extern int __net_init  fib_proc_init(struct net *net);
 extern void __net_exit fib_proc_exit(struct net *net);
-#endif
+#else /* CONFIG_PROC_FS */
+static inline int fib_proc_init(struct net *net)
+{
+	return 0;
+}
+
+static inline int fib_proc_exit(struct net *net)
+{
+	return 0;
+}
+
+#endif /* CONFIG_PROC_FS */
 
 #endif  /* _NET_FIB_H */
Index: linux-2.6.24-mm1/include/net/ipv6.h
===================================================================
--- linux-2.6.24-mm1.orig/include/net/ipv6.h	2008-02-07 13:40:38.000000000 +0100
+++ linux-2.6.24-mm1/include/net/ipv6.h	2008-02-12 11:16:27.000000000 +0100
@@ -586,9 +586,6 @@ extern int ip6_mc_msfget(struct sock *sk
 			 int __user *optlen);
 
 #ifdef CONFIG_PROC_FS
-extern struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
-extern struct ctl_table *ipv6_route_sysctl_init(struct net *net);
-
 extern int  ac6_proc_init(void);
 extern void ac6_proc_exit(void);
 extern int  raw6_proc_init(void);
@@ -621,6 +618,9 @@ static inline int snmp6_unregister_dev(s
 extern ctl_table ipv6_route_table_template[];
 extern ctl_table ipv6_icmp_table_template[];
 
+extern struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
+extern struct ctl_table *ipv6_route_sysctl_init(struct net *net);
+
 extern int ipv6_sysctl_register(void);
 extern void ipv6_sysctl_unregister(void);
 #endif

--------------030102020103080703060209--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
